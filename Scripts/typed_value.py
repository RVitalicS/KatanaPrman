
from Katana import NodegraphAPI
time = int(NodegraphAPI.GetCurrentTime())



def get ( parameter ):

    data = dict(value=None, expression=False)

    if parameter.isExpression():
        data["value"] = parameter.getExpression()
        data["expression"] = True
    else:
        data["value"] = parameter.getValue(time)

    return data



def set ( data, parameter ):

    value      = data["value"]
    expression = data["expression"]

    if expression:
        parameter.setExpression(value, time)
        parameter.setExpressionFlag(True)
    else:
        parameter.setValue(value, time)
