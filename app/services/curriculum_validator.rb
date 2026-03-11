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

  UNVISITED = :unvisited
  IN_STACK  = :in_stack
  DONE      = :done

  # Validates an array of lesson-like objects for DAG integrity.
  # Each lesson must respond to :id and :prerequisite_ids.
  # Raises CyclicDependencyError if any cycle is detected.
  # Raises InvalidPrerequisiteError if any prereq ID is not in the lessons set.
  def self.validate!(lessons)
    id_set = lessons.map(&:id).to_set
    validate_prerequisite_ids!(lessons, id_set)
    adjacency_graph = build_adjacency_graph(lessons)
    detect_cycles!(id_set, adjacency_graph)
  end

  def self.validate_prerequisite_ids!(lessons, id_set)
    lessons.each do |lesson|
      lesson.prerequisite_ids.each do |prereq_id|
        unless id_set.include?(prereq_id)
          raise InvalidPrerequisiteError,
            "Lesson #{lesson.id} (#{lesson.title}) references non-existent prerequisite ID #{prereq_id}"
        end
      end
    end
  end
  private_class_method :validate_prerequisite_ids!

  def self.build_adjacency_graph(lessons)
    lessons.each_with_object(Hash.new { |h, k| h[k] = [] }) do |lesson, graph|
      lesson.prerequisite_ids.each do |prereq_id|
        graph[prereq_id] << lesson.id
      end
    end
  end
  private_class_method :build_adjacency_graph

  def self.detect_cycles!(id_set, adjacency_graph)
    visit_state = Hash.new(UNVISITED)
    id_set.each do |id|
      dfs_visit!(id, adjacency_graph, visit_state) if visit_state[id] == UNVISITED
    end
  end
  private_class_method :detect_cycles!

  def self.dfs_visit!(node, adjacency_graph, visit_state)
    visit_state[node] = IN_STACK
    adjacency_graph[node].each do |neighbor|
      raise CyclicDependencyError if visit_state[neighbor] == IN_STACK
      dfs_visit!(neighbor, adjacency_graph, visit_state) if visit_state[neighbor] == UNVISITED
    end
    visit_state[node] = DONE
  end
  private_class_method :dfs_visit!
end
