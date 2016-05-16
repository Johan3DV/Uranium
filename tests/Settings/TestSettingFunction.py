# Copyright (c) 2016 Ultimaker B.V.
# Uranium is released under the terms of the AGPLv3 or higher.

import pytest

import UM.Settings.SettingFunction

##  Individual test cases for the good setting functions.
#
#   Each test will be executed with each of these functions. These functions are
#   all good and should work.
setting_function_good_data = [
    "0",            # Number.
    "\"x\"",        # String.
    "True",         # Boolean.
    "foo",          # Variable.
    "math.sqrt(4)", # Function call.
    "foo * zoo"     # Two variables.
]

##  Fixture to create a setting function.
#
#   These setting functions are all built with good functions. Id est no errors
#   should occur during the creation of the fixture.
@pytest.fixture(params = setting_function_good_data)
def setting_function_good(request):
    return UM.Settings.SettingFunction.SettingFunction(request.param)

##  Individual test cases for the bad setting functions.
#
#   Each test will be executed with each of these functions. These functions are
#   all bad and should not work.
setting_function_bad_data = [
    "",                                                                 # Empty string.
    "os.read(os.open(\"/etc/passwd\", os.O_RDONLY), 10)",               # Function that reads your passwords from your system.
    "exec(\"os.read(os.open(\\\"/etc/passwd\\\", os.O_RDONLY), 10)\")", # Obfuscated function that reads your passwords from your system.
    "("                                                                 # Syntax error.
]

##  Fixture to create a setting function.
#
#   These setting functions are all built with bad functions. Id est they should
#   give an error when creating the fixture.
@pytest.fixture(params = setting_function_bad_data)
def setting_function_bad(request):
    return UM.Settings.SettingFunction.SettingFunction(request.param)

##  Tests the initialisation of setting functions with good functions.
#
#   Each of these should create a good function.
def test_init_good(setting_function_good):
    assert setting_function_good is not None
    assert setting_function_good.isValid()

##  Tests the initialisation of setting functions with bad functions.
#
#   Each of these should create a bad function.
def test_init_bad(setting_function_bad):
    assert setting_function_bad is not None
    assert not setting_function_bad.isValid()

class MockValueProvider:
    ##  Creates a mock value provider.
    #
    #   This initialises a dictionary with key-value pairs.
    def __init__(self):
        self._values = {
            "foo": 5,
            "zoo": 7
        }

    ##  Provides a value.
    #
    #   \param name The key of the value to provide.
    def getValue(self, name):
        if not (name in self._values):
            return None
        return self._values[name]

test_call_data = [
    { "code": "0",            "result": 0 },
    { "code": "\"x\"",        "result": "x" },
    { "code": "True",         "result": True },
    { "code": "foo",          "result": 5 },
    { "code": "math.sqrt(4)", "result": 2 },
    { "code": "foo * zoo",    "result": 35 }, # 5 * 7
    { "code": "",             "result": None },
    { "code": "os.read(os.open(\"/etc/passwd\", os.O_RDONLY), 10)", "result": None },
    { "code": "exec(\"os.read(os.open(\\\"/etc/passwd\\\", os.O_RDONLY), 10)\")", "result": None },
    { "code": "boo",          "result": None } # Variable doesn't exist.
]

##  Tests the calling of a valid setting function.
#
#   \param setting_function_good A valid setting function from a fixture.
@pytest.mark.parametrize("data", test_call_data)
def test_call(data):
    value_provider = MockValueProvider()
    function = UM.Settings.SettingFunction.SettingFunction(data["code"])
    assert function(value_provider) == data["result"]

##  Tests the equality operator on setting functions.
def test_eq():
    setting_function = UM.Settings.SettingFunction.SettingFunction("3 * 3")
    assert not (setting_function == "some string") # Equality against something of a different type.
    assert setting_function != "some string"
    assert setting_function == setting_function # Equality against itself.
    assert not (setting_function != setting_function)

    duplicate = UM.Settings.SettingFunction.SettingFunction("3 * 3") # Different instance with the same code. Should be equal!
    assert setting_function == duplicate
    assert not (setting_function != duplicate)

    same_answer = UM.Settings.SettingFunction.SettingFunction("9") # Different code but the result is the same. Should NOT be equal!
    assert not (setting_function == same_answer)
    assert setting_function != same_answer

##  The individual test cases for test_getUsedSettings.
#
#   This is a list where each item is a test case. Each test case consists of a
#   dictionary with two elements: The code that represents a function, and the
#   true variables in that function (the answer).
test_getUsedSettings_data = [
    { "code": "0",       "variables": [] },
    { "code": "\"x\"",   "variables": [] },
    { "code": "x",       "variables": ["x"] },
    { "code": "x * y",   "variables": ["x", "y"] },
    { "code": "sqrt(4)", "variables": ["sqrt"] },
    { "code": "sqrt(x)", "variables": ["sqrt", "x"] },
    { "code": "x * x",   "variables": ["x"] } # Use the same variable twice.
]

##  Tests if the function finds correctly which settings are used.
#
#   \param data A test case to test.
@pytest.mark.parametrize("data", test_getUsedSettings_data)
def test_getUsedSettings(data):
    function = UM.Settings.SettingFunction.SettingFunction(data["code"])
    answer = function.getUsedSettings()
    assert len(answer) == len(data["variables"])
    for variable in data["variables"]: # Check for set equality regardless of the order.
        assert variable in answer

##  Tests the conversion of a setting function to string.
def test_str():
    # Due to the simplicity of the function, it's not really necessary to make a full-blown parametrised test for this. Just two simple tests:
    function = UM.Settings.SettingFunction.SettingFunction("3.14156") # Simple test case.
    assert str(function) == "SettingFunction(3.14156)"
    function = UM.Settings.SettingFunction.SettingFunction("") # Also the edge case.
    assert str(function) == "SettingFunction()"