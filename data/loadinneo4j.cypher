
    //Creation des noeuds

// Création des nœuds Client
LOAD CSV WITH HEADERS FROM 'file:///client.csv' AS row
MERGE (c:Client {id: row.id})
ON CREATE SET
  c.nom = row.nom,
  c.prenom = row.prenom,
  c.date_naissance = row.date_naissance,
  c.email = row.email,
  c.contact = row.contact,
  c.adresse = row.adresse;




// Création des nœuds Produit
LOAD CSV WITH HEADERS FROM 'file:///produit.csv' AS row
MERGE (p:Produit {id: row.id})
ON CREATE SET
  p.nom = row.nom,
  p.description = row.description,
  p.quantite = row.quantite,
  p.prix = row.prix,
  p.statut = row.statut,
  p.categorie = row.categorie;





// Création des nœuds Achat
LOAD CSV WITH HEADERS FROM 'file:///achat.csv' AS row
MERGE (a:Achat {id: row.id})
ON CREATE SET
  a.date_achat = row.date_achat,
  a.statut = row.statut;



// Création des nœuds Fournisseur
LOAD CSV WITH HEADERS FROM 'file:///fournisseur.csv' AS row
MERGE (f:Fournisseur {id: row.id})
ON CREATE SET
  f.nom = row.nom,
  f.prenom = row.prenom,
  f.contact = row.contact,
  f.adresse = row.adresse;



        //Creation de relation



// Relation Client A_ACHETE Achat
LOAD CSV WITH HEADERS FROM 'file:///achat.csv' AS row
MATCH (c:Client {id: row.id_client})
MATCH (a:Achat {id: row.id})
MERGE (c)-[:A_ACHETE]->(a);



// Relation Achat CONCERNE Produit
LOAD CSV WITH HEADERS FROM 'file:///achat.csv' AS row
MATCH (a:Achat {id: row.id})
MATCH (p:Produit {id: row.id_produit})
MERGE (a)-[:CONCERNE]->(p);



// Relation Fournisseur FOURNIT Produit
LOAD CSV WITH HEADERS FROM 'file:///fournisseur_produit.csv' AS row
MATCH (f:Fournisseur {id: row.id_fournisseur})
MATCH (p:Produit {id: row.id_produit})
MERGE (f)-[:FOURNIT {quantite_fournie: row.quantite_fournie, date_fourniture: row.date_fourniture}]->(p);

