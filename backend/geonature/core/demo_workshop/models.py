from sqlalchemy import ForeignKey
from geoalchemy2 import Geometry

from geonature.utils.utilssqlalchemy import serializable, geoserializable
from geonature.utils.env import DB


@serializable
@geoserializable
class OcctaxView(DB.Model):
    __tablename__ = 'v_releve_occtax'
    __table_args__ = {'schema': 'pr_occtax', 'extend_existing':True}
    id_releve_occtax = DB.Column(DB.Integer)
    id_dataset = DB.Column(DB.Integer)
    id_digitiser = DB.Column(DB.Integer)
    date_min = DB.Column(DB.DateTime)
    date_max = DB.Column(DB.DateTime)
    altitude_min = DB.Column(DB.Integer)
    altitude_max = DB.Column(DB.Integer)
    comment = DB.Column(DB.Unicode)
    geom_4326 = DB.Column(Geometry('GEOMETRY', 4326))
