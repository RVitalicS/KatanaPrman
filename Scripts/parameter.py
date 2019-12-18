
import os





def walker ( parameters, function ):


    for parameter in parameters.getChildren():

        if parameter.getChildren():
            walker(parameter, function)

        elif parameter.getType() != "group":
            function(parameter)





def find_strings (node_in, param_in=None):


    # define parameter collector
    parameter_list = []

    # get root parameters form target node
    if not param_in:
        param_in = node_in.getParameters()


    # look for "string" parameters
    for item in param_in.getChildren():

        # for grouped parameters
        # search and append to output list
        if item.getNumChildren() > 0:
            parameter_list += find_strings(node_in, item)

        # append parameters with valid values
        # to parameter collector
        elif item.getType() == "string":
            if os.path.exists(item.getValue(0)):
                parameter_list.append(item)


    # share found parameters
    return parameter_list
