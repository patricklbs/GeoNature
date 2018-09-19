-- DROP TABLE ref_nomenclatures.cor_sensitivity_taxref;

CREATE TABLE ref_nomenclatures.cor_sensitivity_taxref
(
  id_sensitivity serial NOT NULL,
  cd_nom integer NOT NULL,
  id_nomenclature_sensitivity integer NOT NULL,
  sensitivity_duration integer NOT NULL,
  sensitivity_territory character varying(1000),
  date_min date,
  date_max date,
  source character varying(250),
  enable boolean DEFAULT true,
  commentaire character varying(500),
  meta_create_date timestamp without time zone DEFAULT now(),
  meta_update_date timestamp without time zone,
  CONSTRAINT cor_sensitivity_taxref_pkey PRIMARY KEY (id_sensitivity),
  CONSTRAINT fk_cor_sensitivity_taxref_cd_nom FOREIGN KEY (cd_nom)
      REFERENCES taxonomie.taxref (cd_nom) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_cor_sensitivity_taxref_id_nomenclature_sensitivity FOREIGN KEY (id_nomenclature_sensitivity)
      REFERENCES ref_nomenclatures.t_nomenclatures (id_nomenclature) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT check_cor_sensitivity_taxref_niv_precis CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_sensitivity, 'SENSIBILITE'::character varying))
);

-- Trigger: tri_meta_dates_change_cor_sensitivity_taxref on ref_nomenclatures.cor_sensitivity_taxref

-- DROP TRIGGER tri_meta_dates_change_cor_sensitivity_taxref ON ref_nomenclatures.cor_sensitivity_taxref;

CREATE TRIGGER tri_meta_dates_change_cor_sensitivity_taxref
  BEFORE INSERT OR UPDATE
  ON ref_nomenclatures.cor_sensitivity_taxref
  FOR EACH ROW
  EXECUTE PROCEDURE public.fct_trg_meta_dates_change();


-- DROP TABLE ref_nomenclatures.cor_sensitivity_taxref_area;

CREATE TABLE ref_nomenclatures.cor_sensitivity_area
(
  id_sensitivity integer,
  id_area integer,
  CONSTRAINT fk_cor_sensitivity_area_id_area_fkey FOREIGN KEY (id_area)
      REFERENCES ref_geo.l_areas (id_area) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_cor_sensitivity_area_id_sensitivity_fkey FOREIGN KEY (id_sensitivity)
      REFERENCES ref_nomenclatures.cor_sensitivity_taxref (id_sensitivity) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);


 -- lien avec la nomenclature
CREATE TABLE ref_nomenclatures.cor_sensitivity_criteria (
  id_sensitivity integer,
  id_criteria integer,
  CONSTRAINT criteria_id_criteria_fkey FOREIGN KEY (id_criteria)
      REFERENCES ref_nomenclatures.t_nomenclatures (id_nomenclature) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT criteria_id_sensitivity_fkey FOREIGN KEY (id_sensitivity)
      REFERENCES ref_nomenclatures.cor_sensitivity_taxref (id_sensitivity) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- DROP TABLE ref_nomenclatures.cor_sensitivity_area_type;

CREATE TABLE ref_nomenclatures.cor_sensitivity_area_type
(
  id_nomenclature_sensitivity integer,
  id_area_type integer,
  CONSTRAINT cor_sensitivity_area_type_id_area_type_fkey FOREIGN KEY (id_area_type)
      REFERENCES ref_geo.bib_areas_types (id_type) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT cor_sensitivity_area_type_id_nomenclature_sensitivity_fkey FOREIGN KEY (id_nomenclature_sensitivity)
      REFERENCES ref_nomenclatures.t_nomenclatures (id_nomenclature) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

--Dégradation en fonction du niveau de sensibilité
INSERT INTO ref_nomenclatures.cor_sensitivity_area_type VALUES
(ref_nomenclatures.get_id_nomenclature('SENSIBILITE', '1'), ref_geo.get_id_area_type('COM')),
(ref_nomenclatures.get_id_nomenclature('SENSIBILITE', '2'), ref_geo.get_id_area_type('M10')),
(ref_nomenclatures.get_id_nomenclature('SENSIBILITE', '3'), ref_geo.get_id_area_type('DEP'));



--- Fonction calcul de la sensibilité

CREATE OR REPLACE FUNCTION gn_synthese.get_id_nomenclature_sensitivity(
	my_id_obs varchar,
	my_date_obs date,
	my_cd_ref int,
	my_geom geometry,
	my_criterias varchar[]
)
RETURNS integer AS
$BODY$
DECLARE niv_precis integer;
BEGIN
	SELECT INTO niv_precis s.id_nomenclature_sensitivity
	FROM (
		SELECT taxonomie.find_cdref(cd_nom) cd_ref , s.*, l.geom
		FROM ref_nomenclatures.cor_sensitivity_taxref s
		LEFT OUTER JOIN ref_nomenclatures.cor_sensitivity_area  USING(id_sensitivity)
		LEFT OUTER JOIN ref_geo.l_areas l USING(id_area)
		WHERE s.enable=true
	)s
	WHERE my_cd_ref = s.cd_ref
		AND (st_intersects(st_transform(my_geom, 2154), s.geom) OR s.geom IS NULL) -- paramètre géographique
		AND (-- paramètre période
			(to_char(my_date_obs, 'MMDD') between to_char(s.date_min, 'MMDD') and to_char(s.date_max, 'MMDD') )
			OR
			(date_min IS NULL)
		)
		AND ( -- paramètre duré de validité de la règle
			(date_part('year', CURRENT_TIMESTAMP) - sensitivity_duration) <= date_part('year', my_date_obs)
		);

	if niv_precis IS NULL THEN
		niv_precis = 0;
	END IF;

	return niv_precis;

END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
