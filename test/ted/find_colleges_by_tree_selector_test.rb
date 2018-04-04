# encoding: utf-8
require_relative '../test_helper'

# TS-382: TED Regression
# UI Test: Find College Filters

=begin
  Coach Admin Tiffany
  Check college filters:
    - Filter results by tree selector: region, major
    - Filter by individual selector first
    - Filter by both
=end

class FindCollegesTreeSelectorTest < Minitest::Test
  def setup
    @ui = UI.new 'local', 'firefox'
    @browser = @ui.driver
    UIActions.setup(@browser)
    TED.setup(@browser)

    goto_find_colleges
  end

  def teardown
    @browser.close
  end

  def goto_find_colleges
    UIActions.ted_login
    TED.goto_colleges
  end

  def open_filter
    @browser.button(:text, 'Filter Results').click
  end

  def apply_filters
    @browser.button(:text, 'Apply Filters').click
    UIActions.wait_for_spinner
  end

  def colleges
    @browser.elements(:class, 'card-college').to_a
  end

  def get_tree_node(element_id)
    section = @browser.div(:id, element_id)
    section.elements(:class, 'tree-node').to_a.sample
  end

  def get_region_states(treenode)
    all_states = []
    treenode.elements(:class, 'tree-node').each |node|
      all_states << node.attribute_value('data-node-id')
    end

    all_states
  end

  def test_filter_result_by_region
    treenode = get_tree_node('some_id')
    region = treenode.attribute_value('data-node-id')
    all_states = get_region_states(treenode)
    treenode.click
    apply_filters

    # examine 5 random schools
    failure = []
    for i in 1 .. 5
      college = colleges.sample
      college_name = college.element(:tag_name, 'h4').text
      state = college.element(:class, 'subtitle').text.split(' ')[3]
      failure << "#{college_name} not in #{region}" unless all_states.include? state
    end
  end

  def test_filter_result_by_major
  end
end
