
/****** Object:  Table t_client    Script Date: 14/09/2017 03:36:50 ******/
use master
go
if exists(select * from sys.databases where name='db_medical_store')
drop database db_medical_store
go
create database db_medical_store
go
use db_medical_store

--------------------------------------------- Codes Province --------------------------------------------------------
go
create table t_province
(
	id_province nvarchar(50),
	description_province nvarchar(50),
	constraint pk_province primary key(id_province)
);

------------------------procedure enregistrer_province
go
create procedure enregistrer_province
(
	@id_province nvarchar(50),
	@description_province nvarchar(50)
)
as
begin
	if not exists(select * from t_province where id_province = @id_province)
		insert into t_province values(@id_province, @description_province)
	else
	update t_province set description_province = @description_province where id_province = @id_province
end


---------------------procedure recuperer_province

go
create procedure recuperer_province
as
	select id_province from t_province
		order by id_province asc

---------------------procedure supprimer_province
go
create procedure supprimer_province
@id_province nvarchar(50)
as
	delete from t_province
		where
			id_province=@id_province
------------------------------------------ fin codes province-------------------------------------------------------
---------------------------------------------- Codes Ville ---------------------------------------------------------

go
create table t_ville
(
	id_ville nvarchar(50),
	description_ville nvarchar(50),
	id_province nvarchar(50),
	constraint pk_ville primary key(id_ville),
	constraint fk_province_ville foreign key(id_province) references t_province(id_province) on delete cascade on update cascade
)

-----------------procedure enregistrer_ville

go
create procedure enregistrer_ville
(
	@id_ville nvarchar(50),
	@description_ville nvarchar(50),
	@province nvarchar(50)
)
as
begin
	declare @id_province nvarchar(50) = (select id_province from t_province where description_province = @province)
	if not exists (select * from t_ville where id_ville = @id_ville)
		insert into t_ville values (@id_ville, @description_ville, @id_province)
	else
		update t_ville set description_ville = @description_ville, id_province = @id_province where id_ville = @id_ville
end


-----------------procedure recuperer_ville

go
create procedure recuperer_ville
as
select id_ville from t_ville
	order by id_ville asc

--------------- procedure supprimer_ville

go
create procedure supprimer_ville
@id_ville nvarchar(50)
as
	delete from t_ville
		where
			id_ville=@id_ville
-------------------------------Fin Codes Villes---------------------------------------------------
--------------------------------------Codes Zones--------------------------------------------------

go
create table t_zone
(
	id_zone nvarchar(50),
	descr_zone nvarchar(50),
	adresse nvarchar(100),
	telephone nvarchar(50),
	id_ville nvarchar(50),
	constraint pk_primary primary key(id_zone),
	constraint fk_zone_ville foreign key(id_ville) references t_ville(id_ville) on delete cascade on update cascade
)


-------------procedure afficher_zone
go
create procedure afficher_zone
as
	select top 50 id_zone as 'code zone', descr_zone as 'description', adresse as 'adresse', telephone as 'telephone', id_ville as 'ville'  
	from t_zone
		order by id_ville asc, id_zone asc

------------procedure enregistrer_zone

go
create procedure enregistrer_zone
@id_zone nvarchar(50),
@descr_zone nvarchar(50),
@adresse nvarchar(100),
@telephone nvarchar(50),
@ville nvarchar(50)
as
	declare @id_ville nvarchar(50) = (select id_ville from t_ville where description_ville = @ville)
	merge into t_zone
	using (select @id_zone as x_id) as x_source
		on(x_source.x_id = t_zone.id_zone)
			when matched then
			 update set
				descr_zone=@descr_zone,
				adresse=@adresse,
				telephone=@telephone,
				id_ville=@id_ville
			when not matched then
				insert 
					(id_zone, descr_zone, adresse, telephone, id_ville)
				values
					(@id_zone, @descr_zone, @adresse, @telephone, @id_ville);
go
create procedure supprimer_zone
@id_zone nvarchar(50)
as
	delete from t_zone
		where
			id_zone=@id_zone
go
create procedure recuperer_zone
as
	select id_zone from t_zone	
		order by id_zone asc

-----------------------------------Fin Codes Zone--------------------------------------------------
-----------------------------------Debut Codes Structure-------------------------------------------
go
create table t_structure
(
	id_structure nvarchar(50),
	descr_structure nvarchar(50),
	adresse nvarchar(50),
	telephone nvarchar(50),
	id_zone nvarchar(50),
	constraint pk_structure primary key(id_structure),
	constraint fk_structure_zone foreign key(id_zone) references t_zone(id_zone) on delete cascade on update cascade
)

----------------- procedure afficher_structure

go
create procedure afficher_structure
as
	select top 50 id_structure as 'ID Structure', descr_structure as 'description', adresse as 'adresse', telephone as 'telephone', id_zone as 'Zone de Sante'  
	from t_structure
		order by id_structure asc

------------------ procedure enregistrer_structure

go
create procedure enregistrer_structure
@id_structure nvarchar(50),
@descr_structure nvarchar(50),
@adresse nvarchar(50),
@telephone nvarchar(50),
@zone nvarchar(50)
as
	declare @id_zone nvarchar(50) = (select id_zone from t_zone where descr_zone = @zone)
	merge into t_structure
	using (select @id_structure as x_id) as x_source
		on(x_source.x_id = t_structure.id_structure)
			when matched then
			 update set
				descr_structure=@descr_structure,
				adresse=@adresse,
				telephone=@telephone,
				id_zone=@id_zone
			when not matched then
				insert 
					(id_structure, descr_structure, adresse, telephone, id_zone)
				values
					(@id_structure, @descr_structure, @adresse, @telephone, @id_zone);


--------------------procedure supprimer_structure
go

create procedure supprimer_structure
	@id_structure nvarchar(50)
as
	delete from t_structure
		where
			id_structure=@id_structure

-----------------procedure recuperer_structure

go
create procedure recuperer_structure
as
	select id_structure  from t_structure	
		order by id_structure asc



-----------------------------les recherches structures-zone-ville

go
create procedure recuperer_ville_parID_province
@id_province nvarchar(50)
as
	select id_ville from t_ville
		where
			id_province like id_province
				order by id_ville asc

-------------------------------
go
create procedure recuperer_zone_parID_ville
@id_ville nvarchar(50)
as
select id_zone from t_zone
	where
		id_ville like @id_ville

--------------------------
go
create procedure recuperer_structure_parID_zone
@id_zone nvarchar(50)
as
	select id_structure from t_structure
		where
			id_zone=@id_zone
				order by 
					id_zone asc


-------------------------------- Fin des codes Structures--------------------------------------------------


---------------------------------categorie produit
go
create table t_categorie_prod
(
	code_categorie nvarchar(50),
	designation_categorie nvarchar(50),
	constraint pk_categorie primary key(code_categorie)
);


--------------------procedure enregistrer_categorie

go
create procedure enregistrer_categorie
(
	@code_categorie nvarchar(50),
	@designation_categorie nvarchar(50)
)
as
begin
	if not exists(select * from t_categorie_prod where code_categorie = @code_categorie)
		insert into t_categorie_prod values (@code_categorie, @designation_categorie)
	else
		update t_categorie_prod set designation_categorie = @designation_categorie where code_categorie = @code_categorie
end

--------------------procedure recuperer categorie

go 
create procedure recuperer_categorie
as
	select * from t_categorie_prod order by code_categorie asc


---------------------procedure supprimer_categorie
go
create procedure supprimer_categorie
	@code_categorie nvarchar(50)
as
	delete from t_categorie_prod
		where
			code_categorie=@code_categorie
-------------------------fin categorie_prod-------------------------------------
--------------------------------------------------------- Codes produit------------------------------------------------
go
create table t_produit
(
	code_produit nvarchar(50),
	designation_produit nvarchar(50),
	code_categorie nvarchar(50),
 	constraint pk_equipement primary key(code_produit),
	constraint fk_categorie_prod foreign key(code_categorie) references t_categorie_prod(code_categorie) on delete cascade on update cascade
)

------------ procedure enregistrer_produit

go
create procedure enregistrer_produit
(
	@code_produit nvarchar(50),
	@designation_produit nvarchar(50),
	@categorie nvarchar(50)
)
as
begin
	declare @code_categorie nvarchar(50) = (select code_categorie from t_categorie_prod where designation_categorie = @categorie)
	if not exists(select * from t_produit where code_produit = @code_produit)
		insert into t_produit values (@code_produit, @designation_produit, @code_categorie)
	else
		update t_produit set designation_produit = @designation_produit, code_categorie = @code_categorie where code_produit = @code_produit
end

------------------ procedure recuperer_produit

go
create procedure recuperer_produit
as
	select * from t_produit order by code_produit asc

---------------------procedure supprimer_produit
go
create procedure supprimer_produit
	@code_produit nvarchar(50)
as
	delete from t_produit
		where
			code_produit=@code_produit

------------------------------------------------------fin codes produits

/****** Object:  Table t_depot     ******/
go
create table t_depot
(
	code_depot nvarchar(50),
	designation_depot nvarchar(50),
 constraint pk_depot primary key (code_depot)
 )

/****** Object:  StoredProcedure enregistrer_depot     ******/

go
create procedure enregistrer_depot
	@code_depot nvarchar(50),
	@designation_depot nvarchar(50)
	as
		merge t_depot as t_depot
		using (select @code_depot, @designation_depot)
			as t_depot_values(v_code_depot, v_designation_depot)
		on (code_depot=v_code_depot)
		when matched then
			update set
				designation_depot=v_code_depot
		when not matched then
			insert (code_depot,designation_depot)
			values(v_code_depot, v_designation_depot);



go
/****** Object:  StoredProcedure afficher_depot     ******/

create procedure afficher_depot
	as
		select top 500 code_depot,designation_depot
			from t_depot
				order by code_depot asc


go
/****** Object:  StoredProcedure charger_depot     ******/

create procedure charger_depot
as
select 
	code_depot from t_depot
	order by code_depot asc
go


go
/****** Object:  StoredProcedure rechercher_depot     ******/

create procedure rechercher_depot
	@code_depot nvarchar(50)
	as
	select * from t_depot
		where code_depot=@code_depot


go
/****** Object:  StoredProcedure supprimer_depot     ******/

create procedure supprimer_depot
	@code_depot nvarchar(50)
	as
	delete from t_depot
		where code_depot=@code_depot

------------------------------------------fin codes depot--------------------------------------------

---------------------------------- Codes fournisseur ------------------------------------------------

go
/****** Object:  Table t_fournisseur     ******/

create table t_fournisseur
(
	code_fournisseur nvarchar(50),
	noms_fournisseur nvarchar(50),
	adresse_fournisseur nvarchar(50),
	telephone_fournisseur nvarchar(50),
	mail_fournisseur nvarchar(50),
 constraint pk_fournisseur primary key (code_fournisseur)
 )


---------------procedure enregistrer_fournisseur

go
create procedure enregistrer_fournisseur
	@code_fournisseur nvarchar(50),
	@noms_fournisseur nvarchar(50),
	@adresse_fournisseur nvarchar(50),
	@telephone_fournisseur nvarchar(50),
	@mail_fournisseur nvarchar(50)
	as
		merge t_fournisseur
			using (select @code_fournisseur, 
						  @noms_fournisseur, 
						  @adresse_fournisseur,
						  @telephone_fournisseur,
						  @mail_fournisseur)
						  as
					t_source_fournisseur
					(
						  code_fournisseur_source,
						  noms_fournisseur_source, 
						  adresse_fournisseur_source,
						  telephone_fournisseur_source,
						  mail_fournisseur_source)
				on(code_fournisseur=code_fournisseur_source)
				when matched then
				update set
					noms_fournisseur=@noms_fournisseur,
					adresse_fournisseur=@adresse_fournisseur,
					telephone_fournisseur=@telephone_fournisseur,
					mail_fournisseur=@mail_fournisseur
				when not matched then
					insert (code_fournisseur,
							noms_fournisseur,
							adresse_fournisseur,
							telephone_fournisseur,
							mail_fournisseur)
					values (@code_fournisseur,
							@noms_fournisseur,
							@adresse_fournisseur,
							@telephone_fournisseur,
							@mail_fournisseur);

go
/****** Object:  StoredProcedure afficher_fournisseur     ******/

create procedure afficher_fournisseur
	as
		select top 500 code_fournisseur, 
					   noms_fournisseur, 
					   adresse_fournisseur, 
					   telephone_fournisseur, 
					   mail_fournisseur
		from t_fournisseur
				order by noms_fournisseur asc


go

create procedure rechercher_fournisseur
	@code_fournisseur nvarchar(50)
	as
		select top 500 code_fournisseur, 
					   noms_fournisseur, 
					   adresse_fournisseur, 
					   telephone_fournisseur, 
					   mail_fournisseur
		from t_fournisseur
			where code_fournisseur=@code_fournisseur
				order by noms_fournisseur asc


go
/****** Object:  StoredProcedure charger_fournisseur     ******/

create procedure charger_fournisseur
as
select
	code_fournisseur 
	from t_fournisseur
	order by code_fournisseur asc

/****** Object:  StoredProcedure supprimer_fournisseur     ******/

go
create procedure supprimer_fournisseur
	@code_fournisseur nvarchar(50)
	as
		delete from t_fournisseur
			where code_fournisseur=@code_fournisseur


-----------------------------------------------fin codes fournisseur-----------------------------------------

----------------------------------------------- Codes approvisionnement-------------------------------
go
/****** Object:  Table t_approvisionnement  ******/
create table t_approvisionnement
(
	code_approvisionnement nvarchar(50),
	date_approvisionnement date,
	date_fabrication date,
	date_expiration date,
	code_produit nvarchar(50),
	code_fournisseur nvarchar(50),
	code_depot nvarchar(50),
    ugs nvarchar, ----unite de gestion de stock, milligrammes
	quantite int,
	cout_total decimal(18,0),
	
 constraint pk_approvisionnement primary key(code_approvisionnement),
 constraint fk_fournisseur_approv foreign key(code_fournisseur) references t_fournisseur(code_fournisseur),
 constraint fk_produit_approv foreign key(code_produit) references t_produit(code_produit),
 constraint fk_depot_approv foreign key(code_depot) references t_depot(code_depot), 
)


go
/****** Object:  StoredProcedure inserer_approvisionnement     ******/

create procedure inserer_approvisionnement
	@code_approvisionnement nvarchar(50),
	@date_approvisionnement date,
	@code_fournisseur nvarchar(50),
	@code_depot nvarchar(50),
	@quantite int,
	@cout_total decimal
	as
		merge t_approvisionnement
		using (select @code_approvisionnement, @date_approvisionnement, @code_fournisseur, @code_depot, @quantite, @cout_total) 
			as xapprovisionnement(xcode_approvisionnement, xdate_approvisionnement, xcode_fournisseur, xcode_depot, xquantite, xcout_total)
		on(t_approvisionnement.code_approvisionnement=xapprovisionnement.xcode_approvisionnement)
		when matched then
			update set
				date_approvisionnement=@date_approvisionnement,
				code_fournisseur=@code_fournisseur,
				code_depot=@code_depot,
				quantite=@quantite,
				cout_total=@cout_total
		when not matched then
			insert (code_approvisionnement, date_approvisionnement, code_fournisseur, code_depot, quantite, cout_total)
			values (@code_approvisionnement, @date_approvisionnement, @code_fournisseur, @code_depot, @quantite, @cout_total);




go
/****** Object:  StoredProcedure supprimer_approvisionnement     ******/

create procedure supprimer_approvisionnement
	@code_approvisionnement nvarchar(50)
	as
	delete from t_approvisionnement
		where code_approvisionnement=@code_approvisionnement

go
/****** Object:  StoredProcedure rechercher_approvisionnement_entre_date     ******/

create procedure rechercher_approvisionnement_entre_date
	@date_un date,
	@date_deux date
	as
	select * from t_approvisionnement
		where date_approvisionnement between @date_un and @date_deux
			order by code_approvisionnement desc



GO
/****** Object:  StoredProcedure afficher_approvisionnement     ******/

create procedure afficher_approvisionnement
as
select top 500 code_approvisionnement as 'Code', date_approvisionnement as 'Date', code_fournisseur as 'Fournisseur', code_depot as 'Depot', quantite as 'Qte', cout_total as 'Prix'
	from t_approvisionnement
		order by date_approvisionnement desc, code_approvisionnement desc



go
/****** Object:  StoredProcedure charger_approvisionnement     ******/

create procedure charger_approvisionnement
as
	select 
	code_approvisionnement
	from t_approvisionnement
	order by code_approvisionnement desc

--------------------------------------------------------------fin codes approvisionnement------------------------------------------

------------------------------------Debut codes de la commande-------------------------------------------------------------

go
create table t_commandes
	(
	num_commande int identity,
	code_produit nvarchar(50),
	qte decimal,
	alerte_level nvarchar(50),------- critique,
	date_commande date,
  id_structure nvarchar(50),
  constraint pk_commande primary key (num_commande),
	constraint fk_commandes_structure foreign key(id_structure) references t_structure(id_structure)
)


---------------------------------------
go
create procedure inserer_commande
@code_produit nvarchar(50),
@qte decimal,
@alerte_level nvarchar(50),
@date_commande date,
@id_structure nvarchar(50)
as
	insert into t_commandes
		(code_produit, qte, alerte_level, date_commande, id_structure)
	values
		(@code_produit, @qte, @alerte_level, @date_commande, @id_structure)

----------------------------------------


--------------------------------------------

go
create procedure supprimer_commande
@num_commande int
as
	delete from t_commandes
		where
			num_commande=@num_commande

	
-----------------------------------Fin des codes de la commande-----------------------------------------------------------

/****** Object:  Table t_attribution_facture    ******/
go
create table t_transporteur
(
	code_transporteur nvarchar(50),
	descr_transporteur nvarchar(50),
	num_phone nvarchar(50),
	adresse_transporteur nvarchar(50),
	constraint pk_transporteur primary key(code_transporteur)
);

go
create procedure enregistrer_transporteur
	@code_transporteur nvarchar(50),
	@descr_transporteur nvarchar(50),
	@num_phone nvarchar(50),
	@adresse_transporteur nvarchar(50)
as
	insert into t_transporteur 
		(code_transporteur, descr_transporteur, num_phone, adresse_transporteur)
	values
		(@code_transporteur, @descr_transporteur, @num_phone, @adresse_transporteur);

go
create table t_distribution
	(
		num_distribution int identity,
		date_distribution date,
		code_transporteur nvarchar(50),
		num_commande int,
		code_approvisionnement nvarchar(50),
		qte_demande decimal,
		descr_distribution nvarchar(50),
		constraint pk_distribution primary key(num_distribution),
		constraint fk_distr_approv foreign key(code_approvisionnement) references t_approvisionnement(code_approvisionnement) on delete cascade on update cascade,
		constraint fk_distr_commande foreign key(num_commande) references t_commandes(num_commande) on delete cascade on update cascade,
		constraint fk_distr_transporteur foreign key(code_transporteur) references t_transporteur(code_transporteur) on delete cascade on update cascade
	)


go
create table t_confirmation_reception
(
	num_confirmation int identity,
	num_commande int,
	date_confirmation date,
	qte_recue decimal,
    observations nvarchar(500),
	constraint pk_confirmation primary key(num_confirmation),
	constraint fk_conf_commande foreign key(num_commande) references t_commandes (num_commande) on delete cascade on update cascade ---modified
);


-------------------------------------------------------Codes Login------------------------------------------------------------------
/****** Object:  Table t_login     ******/

create table t_login(
	nom_utilisateur nvarchar(50),
	mot_de_passe nvarchar(50),
	niveau_acces nvarchar(50),
 constraint pk_login primary key(nom_utilisateur)
 )

 
go
/****** Object:  StoredProcedure enregistrer_login     ******/

create procedure enregistrer_login
	@nom_utilisateur nvarchar(50),
	@mot_de_passe nvarchar(50),
	@niveau_acces nvarchar(50)
	as
	merge t_login as t_logins
	using(select @nom_utilisateur, @mot_de_passe, @niveau_acces) 
		as t_parametres(prm_nom_utilisateur, prm_mot_de_passe, prm_niveau_acces)
	on(t_logins.nom_utilisateur=t_parametres.prm_nom_utilisateur)
		when matched then
			update set mot_de_passe=t_parametres.prm_mot_de_passe,
					   niveau_acces=t_parametres.prm_niveau_acces
		when not matched then
			insert (nom_utilisateur, mot_de_passe, niveau_acces)
			values(@nom_utilisateur, @mot_de_passe, @niveau_acces);



go
/****** Object:  StoredProcedure supprimer_login     ******/

create procedure supprimer_login
	@nom_utilisateur nvarchar(50)
	as
	delete from t_login
		where nom_utilisateur=@nom_utilisateur;


go
/****** Object:  StoredProcedure rechercher_login     ******/

create procedure rechercher_login
	@nom_utilisateur nvarchar(50),
	@mot_de_passe nvarchar(50)
	as
	select niveau_acces from t_login 
		where nom_utilisateur 
			like @nom_utilisateur and mot_de_passe=@mot_de_passe
go
-------------------------------------------------------- fin Codes Login-----------------------------------------------------------

----------------------------------------------------Codes facture--------------------------------------------------------------------
/*create procedure rechercher_facure
@code_facture nvarchar(50)
as
select        
	t_approvisionnement.date_approvisionnement, 
	t_approvisionnement.code_approvisionnement, 
    t_facture.code_facture, 
	t_facture.date_facture, 
	t_client.noms_client, 
	t_details_facture.qte_vendue, 
	t_details_facture.prix_unitaire, 
	t_details_facture.prix_total
from            
	t_approvisionnement inner join t_details_facture on
		t_approvisionnement.code_approvisionnement = t_details_facture.code_approvisionnement 
		inner join
        t_facture on t_details_facture.code_facture = t_facture.code_facture inner join
                         t_equipement on t_approvisionnement.code_equipement = t_equipement.code_equipement inner join
                         t_client on t_facture.matricule_client = t_client.matricule_client
						 where t_facture.code_facture=@code_facture


*/

------------------------------------------------ Codes stock -------------------------------------------


go
create table t_stock
(
	numero int identity,
	date_stock date,
	designation nvarchar(50),
	stock_initial decimal,
	qte_entree decimal,
	qte_sortie decimal,
	stock_final decimal,
	constraint pk_stock primary key(numero)
)
go----------------------------------------Debut insertion_stock-----------------------------------------
create procedure inserer_stock
@designation nvarchar(50),
@stock_initial decimal,
@qte_entree decimal,
@qte_sortie decimal,
@stock_final decimal
as
	insert into t_stock
		(date_stock, designation,stock_initial,qte_entree,qte_sortie,stock_final)
	values
		(getdate(), @designation, @stock_initial, @qte_entree, @qte_sortie, @stock_final)
go
--------------------------Fin ajout stock informations -------------------------------------------------
-------------------------- procedure rechercher_stock

go
create procedure rechercher_stock
as
	select top 500
		date_stock,
		designation,
		stock_initial,
		qte_entree,
		qte_sortie,
		stock_final
	from t_stock
		order by date_stock desc, designation desc
go
--------------------------------------------------- fin codes stock----------------------------------------------------------
