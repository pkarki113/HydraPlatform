from HydraServer.lib import project as proj
from HydraServer.lib import network as net
from HydraServer.lib import template as tmpl
from HydraServer.lib import scenario as sen
from HydraServer.lib import attributes as attrs


def load_network(network_id, scenario_id, session):
    return net.get_network(int(network_id),
                           summary=False,
                           include_data='Y',
                           scenario_ids=[scenario_id], **session)

def get_attributes_for_resource(network_id, scenario_id, resource, ids, include_metadata):
    return net.get_attributes_for_resource(network_id, scenario_id, resource, ids, include_metadata)

def get_resource_data(resource, id, scenario_id, type_id, session):
    return sen.get_resource_data(resource, id, scenario_id, type_id, **session)

def get_network_extents(network_id, session):
    return net.get_network_extents(network_id, **session)

def add_network(network, user_id):
    new_network = net.add_network(network, user_id=user_id)
    return new_network

def add_node(node, user_id):
    new_node = net.add_node(node.network_id, node, user_id=user_id)
    return new_node

def update_node(node, user_id):
    updated_node = net.update_node(node, user_id=user_id)
    return updated_node

def add_link(link, user_id):
    new_link = net.add_link(link.network_id, link, user_id=user_id)
    return new_link

def get_all_attributes():
    return attrs.get_attributes()

def add_attr(attr, user_id):
    new_attr =  attrs.add_attribute(attr, user_id=user_id)
    return new_attr

def add_template(template, user_id):
    new_tmpl =  tmpl.add_template(template, user_id=user_id)
    return new_tmpl

def update_template(template, user_id):
    updated_tmpl =  tmpl.update_template(template, user_id=user_id)
    return updated_tmpl

def get_template(template_id, user_id):
    template =  tmpl.get_template(template_id, user_id=user_id)
    return template

def delete_template(template_id, user_id):
    status =  tmpl.delete_template(template_id, user_id=user_id)
    return status

def get_all_templates(user_id, load_all=False):
    all_templates =  tmpl.get_templates(load_all=load_all, user_id=user_id)
    return all_templates 
