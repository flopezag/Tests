from behave import given, step
from config.settings import CODE_HOME
from os.path import join
from time import sleep

@given(u'I set the tutorial 301 LD - Timedata series')
def step_impl(context):
    context.data_home = join(join(join(CODE_HOME, "features"), "data"), "301.ld.Time_Series_Data")

@step(u'Wait for debug')
def wait_for_debug_301ld(context):
    sleep(1)