# frozen_string_literal: true

module Store
  module_function

  def save_session(session_id, positions)
    battleships[session_id] = Array(positions).map(&:serialize)
  end

  def get_session(session_id)
    battleships[session_id]
  end

  def battleships
    @battleships ||= {}
  end
  private :battleships
end
