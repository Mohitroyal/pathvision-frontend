-- PathVision OS: Production Supabase Schema
-- Architecture: Real-time, Interconnected Neural OS
-- Database: PostgreSQL 15+

-- Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==================================================
-- 1. ENUMS & TYPES
-- ==================================================

DO $$ BEGIN
    CREATE TYPE task_status AS ENUM ('todo', 'in_progress', 'review', 'done', 'blocked');
    CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'critical');
    CREATE TYPE risk_severity AS ENUM ('monitor', 'plan', 'critical', 'overdue');
    CREATE TYPE milestone_status AS ENUM ('planned', 'in_progress', 'at_risk', 'completed');
    CREATE TYPE impact_level AS ENUM ('low', 'medium', 'high', 'extreme');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ==================================================
-- 2. CORE TABLES
-- ==================================================

-- Users & Profiles
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    role TEXT DEFAULT 'user',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Departments
CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Projects
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'active',
    owner_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    start_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    progress DECIMAL DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tasks
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    status task_status DEFAULT 'todo',
    priority task_priority DEFAULT 'medium',
    assigned_to UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    due_date TIMESTAMPTZ,
    is_pinned BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subtasks
CREATE TABLE IF NOT EXISTS public.subtasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Milestones
CREATE TABLE IF NOT EXISTS public.milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date DATE,
    status milestone_status DEFAULT 'planned',
    is_pinned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Goals
CREATE TABLE IF NOT EXISTS public.goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    target_value DECIMAL DEFAULT 100,
    current_value DECIMAL DEFAULT 0,
    deadline DATE,
    category TEXT DEFAULT 'GENERAL',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Risks
CREATE TABLE IF NOT EXISTS public.risks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    impact impact_level DEFAULT 'medium',
    probability impact_level DEFAULT 'medium',
    severity risk_severity DEFAULT 'monitor',
    mitigation TEXT,
    owner UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Planner Blocks
CREATE TABLE IF NOT EXISTS public.planner_blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    task_id UUID REFERENCES public.tasks(id) ON DELETE SET NULL,
    title TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Brain Dump
CREATE TABLE IF NOT EXISTS public.brain_dump (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    category TEXT DEFAULT 'idea',
    is_processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Finance / Transactions
CREATE TABLE IF NOT EXISTS public.finance_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    type TEXT CHECK (type IN ('income', 'expense')),
    date DATE DEFAULT CURRENT_DATE,
    category TEXT DEFAULT 'misc',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Knowledge Base
CREATE TABLE IF NOT EXISTS public.knowledge_base (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    tags TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================================================
-- 3. NEURAL AUTOMATION (TRIGGERS & FUNCTIONS)
-- ==================================================

-- Function: Auto-update Project Progress
CREATE OR REPLACE FUNCTION public.update_project_progress()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.projects
    SET progress = (
        SELECT COALESCE(COUNT(CASE WHEN status = 'done' THEN 1 END)::DECIMAL / NULLIF(COUNT(*), 0), 0) * 100
        FROM public.tasks
        WHERE project_id = NEW.project_id
    )
    WHERE id = NEW.project_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_task_status_change
AFTER UPDATE OF status ON public.tasks
FOR EACH ROW EXECUTE FUNCTION public.update_project_progress();

-- Function: Auto-create Risks for Overdue Tasks
CREATE OR REPLACE FUNCTION public.check_overdue_tasks()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.due_date < NOW() AND NEW.status != 'done' THEN
        INSERT INTO public.risks (project_id, title, description, severity, impact)
        VALUES (NEW.project_id, 'Overdue: ' || NEW.title, 'System auto-detected overdue task.', 'overdue', 'high')
        ON CONFLICT DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_task_overdue
AFTER INSERT OR UPDATE ON public.tasks
FOR EACH ROW EXECUTE FUNCTION public.check_overdue_tasks();

-- ==================================================
-- 4. REALTIME CONFIGURATION
-- ==================================================

-- Enable Realtime for core modules
ALTER publication supabase_realtime ADD TABLE tasks;
ALTER publication supabase_realtime ADD TABLE projects;
ALTER publication supabase_realtime ADD TABLE milestones;
ALTER publication supabase_realtime ADD TABLE planner_blocks;
ALTER publication supabase_realtime ADD TABLE finance_transactions;
ALTER publication supabase_realtime ADD TABLE brain_dump;
ALTER publication supabase_realtime ADD TABLE risks;

-- ==================================================
-- 5. RLS POLICIES (Production Setup)
-- ==================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Allow public read for now (as per prototype needs) but restrict writes to authenticated
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- ==================================================
-- 6. SEARCH INDEXING
-- ==================================================
CREATE INDEX idx_tasks_search ON public.tasks USING GIN (to_tsvector('english', title || ' ' || COALESCE(description, '')));
CREATE INDEX idx_brain_dump_search ON public.brain_dump USING GIN (to_tsvector('english', content));
