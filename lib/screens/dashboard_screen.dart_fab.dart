  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: _gold,
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTaskScreen())),
      child: const Icon(Icons.add, color: _bg),
    );
  }
}
