Voici ton fichier transformé en Markdown :

```markdown
# Stratégie 1 : Toute la donnée est écrite en Cypher dans l’optique d’importer

## Création des nœuds Client
```cypher
CREATE (c:Client {
    id: 1,
    nom: "Dupont",
    prenom: "Jean",
    email: "dupont@example.com",
    contact: "0123456789",
    adresse: "123 Rue de Paris"
});
```

## Création des nœuds Produit
```cypher
CREATE (p:Produit {
    id: 101,
    nom: "Produit A",
    description: "Description du produit A",
    quantite: 50,
    prix: 10.5,
    statut: "Disponible",
    categorie: "Catégorie 1"
});
```

## Création des nœuds Achat
```cypher
CREATE (a:Achat {
    id: 1001,
    date_achat: "2023-10-01",
    statut: "Terminé"
});
```

## Création des relations (Client)-[ACHETE]->(Achat)
```cypher
MATCH (c:Client {id: 1}), (a:Achat {id: 1001})
CREATE (c)-[:ACHETE]->(a);
```

## Création des relations (Achat)-[CONCERNE]->(Produit)
```cypher
MATCH (a:Achat {id: 1001}), (p:Produit {id: 101})
CREATE (a)-[:CONCERNE]->(p);
```

## Création des nœuds Fournisseur
```cypher
CREATE (f:Fournisseur {
    id: 201,
    nom: "Fournisseur X",
    contact: "0123456789",
    adresse: "456 Rue de Lyon"
});
```

## Création des relations (Fournisseur)-[FOURNIT]->(Produit)
```cypher
MATCH (f:Fournisseur {id: 201}), (p:Produit {id: 101})
CREATE (f)-[:FOURNIT]->(p);
```

## Création des nœuds Reclamation
```cypher
CREATE (r:Reclamation {
    id: 501,
    description: "Problème de livraison",
    date: "2023-10-01"
});
```

## Création des relations (Client)-[FAIT_RECLAMATION]->(Reclamation)
```cypher
MATCH (c:Client {id: 1}), (r:Reclamation {id: 501})
CREATE (c)-[:FAIT_RECLAMATION]->(r);
```

## Création des nœuds AvisClient
```cypher
CREATE (a:AvisClient {
    id: 601,
    commentaire: "Très bon produit",
    note: 5
});
```

## Création des relations (Client)-[DONNE_AVIS]->(AvisClient)
```cypher
MATCH (c:Client {id: 1}), (a:AvisClient {id: 601})
CREATE (c)-[:DONNE_AVIS]->(a);
```

---

# Stratégie 2 : L’import depuis une base de données relationnelle

## Step 1: Insertion de la donnée

```sql
INSERT INTO `client` (`id`, `nom`, `prenom`, `date_naissance`, `email`, `contact`, `adresse`) 
VALUES ('1', 'Sanou', 'Ana', '2025-03-04', 'ana@gmail.com', '2557886567', 'rue 22');

INSERT INTO `produit` (`id`, `nom`, `description`, `quantite`, `prix`, `statut`, `categorie`) 
VALUES ('1', 'moto', 'moto d\'occasion', '20', '20000', 'terminé', 'couper');

INSERT INTO `achat` (`id`, `id_client`, `id_produit`, `date_achat`, `statut`) 
VALUES ('1', '1', '1', '2025-03-04', 'valide');

INSERT INTO `fournisseur` (`id`, `nom`, `prenom`, `contact`, `adresse`) 
VALUES ('1', 'Traore', 'sisi', '255788656733', 'Rue 23');

INSERT INTO `fournisseur_produit` (`id_fournisseur`, `id_produit`, `quantite_fournie`, `date_fourniture`) 
VALUES ('1', '1', '20', '2025-03-18');
```

## Step 2: Extraction de la donnée au format CSV avant l'insertion en Cypher

```sql
COPY (SELECT * FROM client) TO '/tmp/client.csv' WITH CSV header;
COPY (SELECT * FROM produit) TO '/tmp/produit.csv' WITH CSV header;
COPY (SELECT * FROM achat) TO '/tmp/achat.csv' WITH CSV header;
COPY (SELECT * FROM fournisseur) TO '/tmp/fournisseur.csv' WITH CSV header;
COPY (SELECT * FROM fournisseur_produit) TO '/tmp/fournisseur_produit.csv' WITH CSV header;
```

## Step 3: Recharger les fichiers CSV

### Création des nœuds

#### Création des nœuds Client
```cypher
LOAD CSV WITH HEADERS FROM 'file:///client.csv' AS row
MERGE (c:Client {id: row.id})
ON CREATE SET 
  c.nom = row.nom,
  c.prenom = row.prenom,
  c.date_naissance = row.date_naissance,
  c.email = row.email,
  c.contact = row.contact,
  c.adresse = row.adresse;
```

#### Création des nœuds Produit
```cypher
LOAD CSV WITH HEADERS FROM 'file:///produit.csv' AS row
MERGE (p:Produit {id: row.id})
ON CREATE SET 
  p.nom = row.nom,
  p.description = row.description,
  p.quantite = row.quantite,
  p.prix = row.prix,
  p.statut = row.statut,
  p.categorie = row.categorie;
```

#### Création des nœuds Achat
```cypher
LOAD CSV WITH HEADERS FROM 'file:///achat.csv' AS row
MERGE (a:Achat {id: row.id})
ON CREATE SET 
  a.date_achat = row.date_achat,
  a.statut = row.statut;
```

#### Création des nœuds Fournisseur
```cypher
LOAD CSV WITH HEADERS FROM 'file:///fournisseur.csv' AS row
MERGE (f:Fournisseur {id: row.id})
ON CREATE SET 
  f.nom = row.nom,
  f.prenom = row.prenom,
  f.contact = row.contact,
  f.adresse = row.adresse;
```

### Création des relations

#### Relation Client A_ACHETE Achat
```cypher
LOAD CSV WITH HEADERS FROM 'file:///achat.csv' AS row
MATCH (c:Client {id: row.id_client})
MATCH (a:Achat {id: row.id})
MERGE (c)-[:A_ACHETE]->(a);
```

#### Relation Achat CONCERNE Produit
```cypher
LOAD CSV WITH HEADERS FROM 'file:///achat.csv' AS row
MATCH (a:Achat {id: row.id})
MATCH (p:Produit {id: row.id_produit})
MERGE (a)-[:CONCERNE]->(p);
```

#### Relation Fournisseur FOURNIT Produit
```cypher
LOAD CSV WITH HEADERS FROM 'file:///fournisseur_produit.csv' AS row
MATCH (f:Fournisseur {id: row.id_fournisseur})
MATCH (p:Produit {id: row.id_produit})
MERGE (f)-[:FOURNIT {quantite_fournie: row.quantite_fournie, date_fourniture: row.date_fourniture}]->(p);
```
```
