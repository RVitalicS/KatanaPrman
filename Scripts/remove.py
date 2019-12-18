
from Scripts import get_port



def dot (node):

    if node.getType() == "Dot":
        
        input_ports = get_port.source(node)

        for input_item in input_ports:
            for input_key in input_item:
                for input_port in input_item[input_key]:

                    output_ports = get_port.target(node)
                    node.delete()

                    for output_item in output_ports:
                        for output_key in output_item:
                            for output_port in output_item[output_key]:

                                input_port.connect(output_port)
