class CurriculumValidator
  class CyclicDependencyError < StandardError
    def initialize(msg = "Circular dependency detected in lesson prerequisite DAG")
      super
    end
  end

  class InvalidPrerequisiteError < StandardError
    def initialize(msg = "Lesson references a prerequisite ID that does not exist")
      super
    end
  end

  # Validates an array of lesson-like objects for DAG integrity.
  # Each lesson must respond to :id and :prerequisite_ids.
  # Raises CyclicDependencyError if any cycle is detected.
  # Raises InvalidPrerequisiteError if any prereq ID is not in the lessons set.
  def self.validate!(lessons)
    id_set = lessons.map(&:id).to_set

    # Validate all prerequisite IDs exist
    lessons.each do |lesson|
      lesson.prerequisite_ids.each do |prereq_id|
        unless id_set.include?(prereq_id)
          raise InvalidPrerequisiteError,
            "Lesson #{lesson.id} (#{lesson.title}) references non-existent prerequisite ID #{prereq_id}"
        end
      end
    end

    # Build adjacency list: prereq → dependent (for DFS cycle detection)
    adj = lessons.each_with_object(Hash.new { |h, k| h[k] = [] }) do |lesson, graph|
      lesson.prerequisite_ids.each do |prereq_id|
        graph[prereq_id] << lesson.id
      end
    end

    # DFS cycle detection using three-color marking
    # white = 0 (unvisited), gray = 1 (in stack), black = 2 (done)
    color = Hash.new(0)

    dfs = lambda do |node|
      color[node] = 1
      adj[node].each do |neighbor|
        if color[neighbor] == 1
          raise CyclicDependencyError
        elsif color[neighbor] == 0
          dfs.call(neighbor)
        end
      end
      color[node] = 2
    end

    id_set.each do |id|
      dfs.call(id) if color[id] == 0
    end
  end
end
