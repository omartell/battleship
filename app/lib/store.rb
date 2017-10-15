module Store
  module_function

  def save_session(session_id, positions)
    battleships[session_id] = positions
  end

  def get_session(session_id)
    battleships[session_id]
  end

  def battleships
    @battleships ||= {}
  end
  private :battleships
end
