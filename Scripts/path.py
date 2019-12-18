

from Katana import NodegraphAPI
import os


time = int(NodegraphAPI.GetCurrentTime())





def make_expression (source, path_core, path_base=''):


    # make sure that paths have the save base symbols
    source = os.path.normpath(source)


    # find the joint base path for input and project paths
    if path_core not in source:

        # move one directory up
        level_up = os.path.dirname(path_core)

        # wrap base expression with move up action
        base_wrapped = 'path.dirname(%s)' % path_base
        return make_expression(source, level_up, base_wrapped)


    # create output string expression and return it
    tail_string = source[len(path_core):]
    tail_list = []
    while tail_string:

        path_level = os.path.basename(tail_string)
        tail_list.insert(0, '"{}"'.format(path_level))

        tail_string = os.path.dirname(tail_string)

        if tail_string == "\\": break
        if tail_string == "/": break

    tail_list.insert(0, path_base)
    expression = 're.sub(r"\\\\", "/", path.normpath( path.join( %s ) ))' % ( ", ".join(tail_list) )

    return expression





def set_relative (parameter):

    value = parameter.getValue(time)
    if os.path.exists(value):

        value = os.path.normpath(value)
        path_core = ''
        path_base = ''


        core_resources = os.path.normpath( os.getenv("PRMAN_RESOURCES", "") )
        if core_resources in value:
            path_core = core_resources
            path_base = 'getenv("PRMAN_RESOURCES", "")'

        core_library = os.path.normpath( os.getenv("TEXLIB", "") )
        if core_library in value:
            path_core = core_library
            path_base = 'getenv("TEXLIB", "")'

        core_assets = os.path.normpath( os.getenv("ASSETS", "") )
        if core_assets in value:
            path_core = core_assets
            path_base = 'getenv("ASSETS", "")'

        if not path_core:
            core_project = os.path.dirname( NodegraphAPI.NodegraphGlobals.GetProjectFile() )
            path_core    = os.path.normpath(core_project)
            path_base    = 'project.dir'


        expression = make_expression(value, path_core, path_base)
        parameter.setExpression('%s' % expression)
