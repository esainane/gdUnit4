# GdUnit generated TestSuite
class_name InspectorTreeMainPanelTest
extends GdUnitTestSuite

# TestSuite generated from
const InspectorTreeMainPanel := preload('res://addons/gdUnit4/src/ui/parts/InspectorTreeMainPanel.gd')

const FAILED := InspectorTreeMainPanel.STATE.FAILED
const ERROR := InspectorTreeMainPanel.STATE.ERROR
const FLAKY := InspectorTreeMainPanel.STATE.FLAKY

var TEST_SUITE_A :String
var TEST_SUITE_B :String
var TEST_SUITE_C :String

var _inspector :InspectorTreeMainPanel


func before_test() -> void:
	_inspector = load("res://addons/gdUnit4/src/ui/parts/InspectorTreePanel.tscn").instantiate()
	add_child(_inspector)
	_inspector.init_tree()

	# load a testsuite
	for test_suite :Node in setup_test_env():
		_inspector.do_add_test_suite(toDto(test_suite))
	# verify no failures are exists
	assert_array(_inspector._on_select_next_item_by_state(FAILED)).is_null()


func after_test() -> void:
	_inspector.cleanup_tree()
	remove_child(_inspector)
	_inspector.free()


func toDto(test_suite :Node) -> GdUnitTestSuiteDto:
	var dto := GdUnitTestSuiteDto.new()
	return dto.deserialize(dto.serialize(test_suite)) as GdUnitTestSuiteDto


func setup_test_env() -> Array:
	var test_suite_a := GdUnitTestResourceLoader.load_test_suite("res://addons/gdUnit4/test/ui/parts/resources/foo/ExampleTestSuiteA.resource")
	var test_suite_b := GdUnitTestResourceLoader.load_test_suite("res://addons/gdUnit4/test/ui/parts/resources/foo/ExampleTestSuiteB.resource")
	var test_suite_c := GdUnitTestResourceLoader.load_test_suite("res://addons/gdUnit4/test/ui/parts/resources/foo/ExampleTestSuiteC.resource")
	TEST_SUITE_A = test_suite_a.get_script().resource_path
	TEST_SUITE_B = test_suite_b.get_script().resource_path
	TEST_SUITE_C = test_suite_c.get_script().resource_path
	return Array([auto_free(test_suite_a), auto_free(test_suite_b), auto_free(test_suite_c)])


func find_item(resource_path :String) -> TreeItem:
	return _inspector.get_tree_item(resource_path, resource_path.get_file().replace(".resource", ""))


func find_test_case(resource_path :String, test_case :String) -> TreeItem:
	return _inspector.get_tree_item(resource_path, test_case)


func set_test_state(test_cases: PackedStringArray, state: InspectorTreeMainPanel.STATE, parent:TreeItem = _inspector._tree_root) -> void:
	assert_object(parent).is_not_null()
	# mark all test as failed
	if parent != _inspector._tree_root:
		_inspector.set_state_succeded(parent)

	var test_event := GdUnitEvent.new().test_after("res://foo.gd", "test_suite", "test_name")

	for item in parent.get_children():
		set_test_state(test_cases, state, item)
		if test_cases.has(item.get_text(0)):
			match state:
				ERROR:
					_inspector.set_state_error(parent)
					_inspector.set_state_error(item)
				FAILED:
					_inspector.set_state_failed(parent, test_event)
					_inspector.set_state_failed(item, test_event)
				FLAKY:
					_inspector.set_state_flaky(parent, test_event)
					_inspector.set_state_flaky(item, test_event)
		else:
			_inspector.set_state_succeded(item)


func get_item_state(parent :TreeItem, item_name :String = "") -> int:
	for item in parent.get_children():
		if item.get_text(0) == item_name:
			return item.get_meta(_inspector.META_GDUNIT_STATE)
	return parent.get_meta(_inspector.META_GDUNIT_STATE)


func test_select_first_failure() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()

	# we have no failures or errors
	_inspector._on_select_next_item_by_state(FAILED)
	assert_object(_inspector._tree.get_selected()).is_null()

	# add failures
	set_test_state(["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"], FAILED)

	# select first failure
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_aa")


func test_select_last_failure() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()

	# we have no failures or errors
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_object(_inspector._tree.get_selected()).is_null()

	# add failures
	set_test_state(["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"], FAILED)
	# select last failure
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")


func test_select_next_failure() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()

	# first time select next but no failure exists
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected()).is_null()

	# add failures
	set_test_state(["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"], FAILED)

	# first time select next than select first failure
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_aa")
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ad")
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cb")
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	# if current last failure selected than select first as next
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_aa")
	_inspector._on_select_next_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ad")


func test_select_previous_failure() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()

	# first time select previous but no failure exists
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected()).is_null()

	# add failures
	set_test_state(["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"], FAILED)

	# first time select previous than select last failure
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cb")
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ad")
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_aa")
	# if current first failure selected than select last as next
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	_inspector._on_select_previous_item_by_state(FAILED)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")


func test_select_next_flaky() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()

	# try select next but no flaky exists
	_inspector._on_select_next_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected()).is_null()

	# add flaky tests
	set_test_state(["test_cb", "test_cc", "test_ce"], FLAKY)

	# first time select next than select first failure
	_inspector._on_select_next_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cb")
	_inspector._on_select_next_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")
	_inspector._on_select_next_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	# if current last failure selected than select first as next
	_inspector._on_select_next_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cb")
	_inspector._on_select_next_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")


func test_select_previous_flaky() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()

	# try select previous but no flaky exists
	_inspector._on_select_previous_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected()).is_null()

	# add failures
	set_test_state(["test_cb", "test_cc", "test_ce"], FLAKY)

	# first time select previous than select last failure
	_inspector._on_select_previous_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	_inspector._on_select_previous_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")
	_inspector._on_select_previous_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cb")
	# if current first failure selected than select last as next
	_inspector._on_select_previous_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	_inspector._on_select_previous_item_by_state(FLAKY)
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")


func test_suite_text_shows_amount_of_cases() -> void:
	var suite_a: TreeItem = find_item(TEST_SUITE_A)
	assert_str(suite_a.get_text(0)).is_equal("(0/5) ExampleTestSuiteA")

	var suite_b: TreeItem = find_item(TEST_SUITE_B)
	assert_str(suite_b.get_text(0)).is_equal("(0/3) ExampleTestSuiteB")


func test_suite_text_responds_to_test_case_events() -> void:
	var suite_a: TreeItem = find_item(TEST_SUITE_A)

	var success_aa := GdUnitEvent.new().test_after(TEST_SUITE_A, "ExampleTestSuiteA", "test_aa")
	_inspector._on_gdunit_event(success_aa)
	assert_str(suite_a.get_text(0)).is_equal("(1/5) ExampleTestSuiteA")

	var error_ad := GdUnitEvent.new().test_after(TEST_SUITE_A, "ExampleTestSuiteA", "test_ad", {GdUnitEvent.ERRORS: true})
	_inspector._on_gdunit_event(error_ad)
	assert_str(suite_a.get_text(0)).is_equal("(1/5) ExampleTestSuiteA")

	var failure_ab := GdUnitEvent.new().test_after(TEST_SUITE_A, "ExampleTestSuiteA", "test_ab", {GdUnitEvent.FAILED: true})
	_inspector._on_gdunit_event(failure_ab)
	assert_str(suite_a.get_text(0)).is_equal("(1/5) ExampleTestSuiteA")

	var skipped_ac := GdUnitEvent.new().test_after(TEST_SUITE_A, "ExampleTestSuiteA", "test_ac", {GdUnitEvent.SKIPPED: true})
	_inspector._on_gdunit_event(skipped_ac)
	assert_str(suite_a.get_text(0)).is_equal("(1/5) ExampleTestSuiteA")

	var success_ae := GdUnitEvent.new().test_after(TEST_SUITE_A, "ExampleTestSuiteA", "test_ae")
	_inspector._on_gdunit_event(success_ae)
	assert_str(suite_a.get_text(0)).is_equal("(2/5) ExampleTestSuiteA")


# test coverage for issue GD-117
func test_update_test_case_on_multiple_test_suite_with_same_name() -> void:
	# add a second test suite where has same name as TEST_SUITE_A
	var test_suite :GdUnitTestSuite = auto_free(GdUnitTestResourceLoader.load_test_suite("res://addons/gdUnit4/test/ui/parts/resources/bar/ExampleTestSuiteA.resource"))
	var test_suite_aa_path :String = test_suite.get_script().resource_path
	_inspector.do_add_test_suite(toDto(test_suite))

	# verify the items exists checked the tree
	assert_str(TEST_SUITE_A).is_not_equal(test_suite_aa_path)
	var suite_a: TreeItem = find_item(TEST_SUITE_A)
	var suite_aa: TreeItem = find_item(test_suite_aa_path)
	assert_object(suite_a).is_not_same(suite_aa)
	assert_str(suite_a.get_meta(_inspector.META_RESOURCE_PATH)).is_equal(TEST_SUITE_A)
	assert_str(suite_aa.get_meta(_inspector.META_RESOURCE_PATH)).is_equal(test_suite_aa_path)

	# verify inital state
	assert_str(suite_a.get_text(0)).is_equal("(0/5) ExampleTestSuiteA")
	assert_int(get_item_state(suite_a, "test_aa")).is_equal(_inspector.STATE.INITIAL)
	assert_str(suite_aa.get_text(0)).is_equal("(0/5) ExampleTestSuiteA")

	# set test starting checked TEST_SUITE_A
	_inspector._on_gdunit_event(GdUnitEvent.new().test_before(TEST_SUITE_A, "ExampleTestSuiteA", "test_aa"))
	_inspector._on_gdunit_event(GdUnitEvent.new().test_before(TEST_SUITE_A, "ExampleTestSuiteA", "test_ab"))
	assert_str(suite_a.get_text(0)).is_equal("(0/5) ExampleTestSuiteA")
	assert_int(get_item_state(suite_a, "test_aa")).is_equal(_inspector.STATE.RUNNING)
	assert_int(get_item_state(suite_a, "test_ab")).is_equal(_inspector.STATE.RUNNING)
	# test test_suite_aa_path is not affected
	assert_str(suite_aa.get_text(0)).is_equal("(0/5) ExampleTestSuiteA")
	assert_int(get_item_state(suite_aa, "test_aa")).is_equal(_inspector.STATE.INITIAL)
	assert_int(get_item_state(suite_aa, "test_ab")).is_equal(_inspector.STATE.INITIAL)

	# finish the tests with success
	_inspector._on_gdunit_event(GdUnitEvent.new().test_after(TEST_SUITE_A, "ExampleTestSuiteA", "test_aa"))
	_inspector._on_gdunit_event(GdUnitEvent.new().test_after(TEST_SUITE_A, "ExampleTestSuiteA", "test_ab"))

	# verify updated state checked TEST_SUITE_A
	assert_str(suite_a.get_text(0)).is_equal("(2/5) ExampleTestSuiteA")
	assert_int(get_item_state(suite_a, "test_aa")).is_equal(_inspector.STATE.SUCCESS)
	assert_int(get_item_state(suite_a, "test_ab")).is_equal(_inspector.STATE.SUCCESS)
	# test test_suite_aa_path is not affected
	assert_str(suite_aa.get_text(0)).is_equal("(0/5) ExampleTestSuiteA")
	assert_int(get_item_state(suite_aa, "test_aa")).is_equal(_inspector.STATE.INITIAL)
	assert_int(get_item_state(suite_aa, "test_ab")).is_equal(_inspector.STATE.INITIAL)


# Test coverage for issue GD-278: GdUnit Inspector: Test marks as passed if both warning and error
func test_update_icon_state() -> void:
	var TEST_SUITE_PATH := "res://addons/gdUnit4/test/core/resources/testsuites/TestSuiteFailAndOrpahnsDetected.resource"
	var TEST_SUITE_NAME := "TestSuiteFailAndOrpahnsDetected"
	var test_suite :GdUnitTestSuite = auto_free(GdUnitTestResourceLoader.load_test_suite(TEST_SUITE_PATH))
	_inspector.do_add_test_suite(toDto(test_suite))

	var suite: TreeItem = find_item(TEST_SUITE_PATH)

	# Verify the inital state
	assert_str(suite.get_text(0)).is_equal("(0/2) "+ TEST_SUITE_NAME)
	assert_str(suite.get_meta(_inspector.META_RESOURCE_PATH)).is_equal(TEST_SUITE_PATH)
	assert_int(get_item_state(suite)).is_equal(_inspector.STATE.INITIAL)
	assert_int(get_item_state(suite, "test_case1")).is_equal(_inspector.STATE.INITIAL)
	assert_int(get_item_state(suite, "test_case2")).is_equal(_inspector.STATE.INITIAL)

	# Set tests to running
	_inspector._on_gdunit_event(GdUnitEvent.new().test_before(TEST_SUITE_PATH, TEST_SUITE_NAME, "test_case1"))
	_inspector._on_gdunit_event(GdUnitEvent.new().test_before(TEST_SUITE_PATH, TEST_SUITE_NAME, "test_case2"))
	# Verify all items on state running.
	assert_str(suite.get_text(0)).is_equal("(0/2) " + TEST_SUITE_NAME)
	assert_int(get_item_state(suite, "test_case1")).is_equal(_inspector.STATE.RUNNING)
	assert_int(get_item_state(suite, "test_case2")).is_equal(_inspector.STATE.RUNNING)

	# Simulate test processed.
	# test_case1 succeeded
	_inspector._on_gdunit_event(GdUnitEvent.new().test_after(TEST_SUITE_PATH, TEST_SUITE_NAME, "test_case1"))
	# test_case2 is failing by an orphan warning and an failure
	_inspector._on_gdunit_event(GdUnitEvent.new()\
		.test_after(TEST_SUITE_PATH, TEST_SUITE_NAME, "test_case2", {GdUnitEvent.FAILED: true}))
	# We check whether a test event with a warning does not overwrite a higher object status, e.g. an error.
	_inspector._on_gdunit_event(GdUnitEvent.new()\
		.test_after(TEST_SUITE_PATH, TEST_SUITE_NAME, "test_case2", {GdUnitEvent.WARNINGS: true}))

	# Verify the final state
	assert_str(suite.get_text(0)).is_equal("(2/2) " + TEST_SUITE_NAME)
	assert_int(get_item_state(suite, "test_case1")).is_equal(_inspector.STATE.SUCCESS)
	assert_int(get_item_state(suite, "test_case2")).is_equal(_inspector.STATE.FAILED)


func test_tree_view_mode_tree() -> void:
	var root: TreeItem = _inspector._tree_root

	var childs := root.get_children()
	assert_array(childs).extract("get_text", [0]).contains_exactly(["(0/13) ui"])


@warning_ignore("unused_parameter")
func test_sort_tree_mode(sort_mode: GdUnitInspectorTreeConstants.SORT_MODE, expected_result: String, test_parameters := [
	[GdUnitInspectorTreeConstants.SORT_MODE.UNSORTED, "tree_sorted_by_UNSORTED"],
	[GdUnitInspectorTreeConstants.SORT_MODE.NAME_ASCENDING, "tree_sorted_by_NAME_ASCENDING"],
	[GdUnitInspectorTreeConstants.SORT_MODE.NAME_DESCENDING, "tree_sorted_by_NAME_DESCENDING"],
	[GdUnitInspectorTreeConstants.SORT_MODE.EXECUTION_TIME, "tree_sorted_by_EXECUTION_TIME"],
	]) -> void:

	# setup tree sort mode
	ProjectSettings.set_setting(GdUnitSettings.INSPECTOR_TREE_SORT_MODE, sort_mode)

	# load example tree
	var tree_sorted :TreeItem = rebuild_tree_from_resource("res://addons/gdUnit4/test/ui/parts/resources/tree/tree_example.json")

	# do sort
	_inspector.sort_tree_items(tree_sorted)

	# verify
	var expected_tree :TreeItem = rebuild_tree_from_resource("res://addons/gdUnit4/test/ui/parts/resources/tree/%s.json" % expected_result)
	assert_tree_equals(tree_sorted, expected_tree)


## test helpers to validate two trees
# ------------------------------------------------------------------------------------------------------------------------------------------


func assert_tree_equals(tree_left :TreeItem, tree_right: TreeItem) -> bool:
	var left_childs := tree_left.get_children()
	var right_childs := tree_right.get_children()

	assert_that(left_childs.size()).is_equal(right_childs.size())
	if is_failure():
		return false

	for index in left_childs.size():
		var l := left_childs[index]
		var r := right_childs[index]

		assert_that(get_item_name(l)).is_equal(get_item_name(r))
		if is_failure():
			_print_tree_up(l)
			_print_tree_up(r)
			_print_execution_times(tree_left)
			_print_execution_times(tree_right)
			return false
		if not assert_tree_equals(l, r):
			return false
	return true


func _print_execution_times(item: TreeItem) -> void:
	for child in item.get_children():
		prints(get_item_name(child), get_item_execution_time(child))
	prints("_________________________________________________")


func _print_tree(tree_left :TreeItem, indent: String = "\t") -> void:
	var left := tree_left.get_children()
	for index in left.size():
		var l := left[index]
		prints(indent, get_item_name(l))
		_print_tree(l, indent+"\t")


func _print_tree_up(item :TreeItem, indent: String = "\t") -> void:
	prints(indent, get_item_name(item))
	var parent := item.get_parent()
	if parent != null:
		_print_tree_up(parent, indent+"\t")


func get_item_name(item: TreeItem) -> String:
	if item.has_meta("gdUnit_name"):
		return "'" + item.get_meta("gdUnit_name") + "'"
	return "''"


func get_item_execution_time(item: TreeItem) -> String:
	if item.has_meta("gdUnit_execution_time"):
		return "'" + str(item.get_meta("gdUnit_execution_time")) + "'"
	return "''"


func rebuild_tree_from_resource(resource: String) -> TreeItem:
	var json := FileAccess.open(resource, FileAccess.READ)
	var dict :Dictionary = JSON.parse_string(json.get_as_text())
	var tree :Tree = auto_free(Tree.new())
	var root := tree.create_item()
	create_tree_item_form_dict(root, dict["TreeItem"] as Dictionary)
	return root


func create_tree_item_form_dict(item: TreeItem, data: Dictionary) -> TreeItem:
	for key:String in data.keys():
		match key:
			"collapsed":
				item.collapsed = data[key] as bool

			"TreeItem":
				var next := item.create_child()
				return create_tree_item_form_dict(next, data[key] as Dictionary)

			"childs":
				var childs_data :Array = data[key]
				for child_data:Dictionary in childs_data:
					create_tree_item_form_dict(item, child_data)

		if key.begins_with("metadata"):
			var meta_key := key.replace("metadata/", "")
			item.set_meta(meta_key, data[key])
	return item
