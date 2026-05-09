-- PathVision OS: Intelligence & Logging Expansion

-- Decision Log
CREATE TABLE IF NOT EXISTS public.decision_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    reasoning TEXT,
    category TEXT DEFAULT 'STRATEGIC',
    date TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Weekly Reports
CREATE TABLE IF NOT EXISTS public.weekly_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    week_number INTEGER NOT NULL,
    year INTEGER NOT NULL,
    efficiency_score DECIMAL DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    focus_hours DECIMAL DEFAULT 0,
    ai_insights TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT,
    type TEXT DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reminders
CREATE TABLE IF NOT EXISTS public.reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    reminder_time TIMESTAMPTZ NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Translation Vault
CREATE TABLE IF NOT EXISTS public.translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    original_text TEXT NOT NULL,
    translated_text TEXT,
    source_lang TEXT,
    target_lang TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Realtime for these
ALTER publication supabase_realtime ADD TABLE decision_log;
ALTER publication supabase_realtime ADD TABLE weekly_reports;
ALTER publication supabase_realtime ADD TABLE notifications;
ALTER publication supabase_realtime ADD TABLE reminders;
ALTER publication supabase_realtime ADD TABLE translations;
