from flask import Blueprint, request, current_app
from geojson import FeatureCollection

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import json_resp
from pypnusershub import routes as fnauth
from geonature.core.demo_workshop.models import OcctaxView


routes = Blueprint('demo_workshop', __name__)

@routes.route('/test', methods=['GET'])
@json_resp
def get_one_test():
    occtax_object = OcctaxView.query.get(1)
    return occtax_object.as_dict()



@routes.route('/test_geo', methods=['GET'])
@json_resp
def get_one_test_geo():
    occtax_object = OcctaxView.query.get(1)
    return occtax_object.as_geofeature('geom_4326', 'id_releve_occtax')




@routes.route('/test_geo_all', methods=['GET'])
@json_resp
def get_all_test_geo():
    data = OcctaxView.query.all()
    occurrences = []
    for occ in data:
        occ_json = occ.as_geofeature('geom_4326', 'id_releve_occtax')
        occurrences.append(occ_json)
    return FeatureCollection(occurrences)


@routes.route('/test_auth', methods=['GET'])
@fnauth.check_auth_cruved('R', True)
@json_resp
def get_test_auth(info_role):
    print(info_role.tag_object_code)
    occtax_object = OcctaxView.query.get(1)
    return occtax_object.as_dict(columns=(id_releve_occtax, date_min))