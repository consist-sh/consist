class NavigationComponent < Bridgetown::Component
  def initialize(resources, recipes)
    @resources = resources + recipes.resources
    @recipes = recipes
  end

  def grouped_and_sorted_documentation_resources
    group_by(@resources, "section")
      .sort_by { |resources| documentation_sections_order.find_index(resources["name"]) }
  end

  private

  def documentation_sections_order
    []
  end
end
