                   VENTES(BDR)


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

                                    STOCK


# STOCK

## Placer le fichier JSON dans Neo4j

Tu dois d'abord déplacer ton fichier JSON (par exemple, `stock.json`) dans le répertoire `import` de Neo4j. Cela permet à Neo4j d'accéder à ce fichier pour charger les données.

## Charger les données JSON dans Neo4j

Une fois le fichier placé dans le répertoire `import` de Neo4j, nous allons utiliser la fonction `apoc.load.json` pour charger les données du fichier JSON. Cela permet à Neo4j de lire le fichier et de l'utiliser pour créer des nœuds et des relations.

## Créer les nœuds

Il y a trois types d'entités dans le fichier JSON : **Produits**, **Fournisseurs**, et **Réapprovisionnements**. Nous allons créer un nœud pour chaque type d'entité dans Neo4j.

### Créer des nœuds Produit

Pour chaque produit dans la liste `produits`, nous allons créer un nœud `Produit` avec les propriétés suivantes : `id`, `nom`, `description`, `quantite_stock`, `prix`, et `categorie`.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///stock.json' AS url
CALL apoc.load.json(url) YIELD value AS row
UNWIND row.produits AS produit
MERGE (p:Produit {id: produit.id})
ON CREATE SET 
  p.nom = produit.nom,
  p.description = produit.description,
  p.quantite_stock = produit.quantite_stock,
  p.prix = produit.prix,
  p.categorie = produit.categorie;
```

### Créer des nœuds Fournisseur

Pour chaque fournisseur dans la liste `fournisseurs`, nous allons créer un nœud `Fournisseur` avec les propriétés `id`, `nom`, `contact`, et `adresse`.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///stock.json' AS url
CALL apoc.load.json(url) YIELD value AS row
UNWIND row.fournisseurs AS fournisseur
MERGE (f:Fournisseur {id: fournisseur.id})
ON CREATE SET 
  f.nom = fournisseur.nom,
  f.contact = fournisseur.contact,
  f.adresse = fournisseur.adresse;
```

### Créer des nœuds Réapprovisionnement

Pour chaque réapprovisionnement dans la liste `reapprovisionnements`, nous allons créer un nœud `Réapprovisionnement` avec les propriétés `id`, `id_produit`, `id_fournisseur`, `quantite_livree`, et `date_livraison`.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///stock.json' AS url
CALL apoc.load.json(url) YIELD value AS row
UNWIND row.reapprovisionnements AS reapprovisionnement
MERGE (r:Reapprovisionnement {id: reapprovisionnement.id})
ON CREATE SET 
  r.quantite_livree = reapprovisionnement.quantite_livree,
  r.date_livraison = reapprovisionnement.date_livraison;
```

## Créer des relations

Après avoir créé les nœuds, nous devons créer des relations entre les entités.

### Relier les Produits aux Réapprovisionnements

Chaque réapprovisionnement concerne un produit. Nous allons créer une relation `CONCERNE` entre chaque réapprovisionnement et le produit correspondant.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///stock.json' AS url
CALL apoc.load.json(url) YIELD value AS row
UNWIND row.reapprovisionnements AS reapprovisionnement
MATCH (p:Produit {id: reapprovisionnement.id_produit})
MATCH (r:Reapprovisionnement {id: reapprovisionnement.id})
MERGE (r)-[:CONCERNE]->(p);
```

### Relier les Fournisseurs aux Réapprovisionnements

Chaque réapprovisionnement provient d'un fournisseur. Nous allons créer une relation `FOURNI_PAR` entre chaque réapprovisionnement et le fournisseur correspondant.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///stock.json' AS url
CALL apoc.load.json(url) YIELD value AS row
UNWIND row.reapprovisionnements AS reapprovisionnement
MATCH (f:Fournisseur {id: reapprovisionnement.id_fournisseur})
MATCH (r:Reapprovisionnement {id: reapprovisionnement.id})
MERGE (r)-[:FOURNI_PAR]->(f);
```

## Vérifier les données dans Neo4j

Une fois que tu as exécuté toutes les requêtes ci-dessus, tu peux vérifier si les nœuds et relations ont bien été créés en exécutant les requêtes suivantes :

### Vérifier les nœuds Produit

```cypher
MATCH (p:Produit) RETURN p LIMIT 25;
```

### Vérifier les nœuds Fournisseur

```cypher
MATCH (f:Fournisseur) RETURN f LIMIT 25;
```

### Vérifier les nœuds Réapprovisionnement

```cypher
MATCH (r:Reapprovisionnement) RETURN r LIMIT 25;
```

### Vérifier les relations entre Réapprovisionnement et Produit

```cypher
MATCH (r:Reapprovisionnement)-[:CONCERNE]->(p:Produit) RETURN r, p LIMIT 25;
```

### Vérifier les relations entre Réapprovisionnement et Fournisseur

```cypher
MATCH (r:Reapprovisionnement)-[:FOURNI_PAR]->(f:Fournisseur) RETURN r, f LIMIT 25;
```

```

                                        CLIENT



Voici la transformation du texte en fichier Markdown :

```markdown
# CLIENT

## Placer le fichier XML dans Neo4j

Tu dois d'abord déplacer ton fichier XML (par exemple, `client.xml`) dans le répertoire `import` de Neo4j. Cela permet à Neo4j d'accéder à ce fichier pour charger les données.

### Placer le fichier XML `clients.xml` dans le répertoire `import` de Neo4j

1. Ouvrir Neo4j Browser (http://localhost:7474).
2. Charger les données XML depuis le fichier avec `apoc.load.xml`.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///clients.xml' AS url
CALL apoc.load.xml(url) YIELD value AS row
```

## Créer les nœuds

### Créer le nœud Client

Pour chaque client dans le fichier XML, nous allons créer un nœud `Client` avec les propriétés suivantes : `id`, `nom`, `prenom`, `email`, `contact`, et `adresse`.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///clients.xml' AS url
CALL apoc.load.xml(url) YIELD value AS row
UNWIND row.clients.client AS client
MERGE (c:Client {id: client.id})
ON CREATE SET 
  c.nom = client.nom,
  c.prenom = client.prenom,
  c.email = client.email,
  c.contact = client.contact,
  c.adresse = client.adresse;
```

### Créer des nœuds Reclamation

Pour chaque réclamation dans la liste de réclamations d'un client, nous allons créer un nœud `Reclamation` avec les propriétés `id`, `description`, et `date`.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///clients.xml' AS url
CALL apoc.load.xml(url) YIELD value AS row
UNWIND row.clients.client AS client
UNWIND client.reclamations.reclamation AS reclamation
MERGE (r:Reclamation {id: reclamation.id})
ON CREATE SET 
  r.description = reclamation.description,
  r.date = reclamation.date;
```

### Créer des nœuds AvisClient

Pour chaque avis dans la liste d'avis d'un client, nous allons créer un nœud `AvisClient` avec les propriétés `id`, `commentaire`, et `note`.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///clients.xml' AS url
CALL apoc.load.xml(url) YIELD value AS row
UNWIND row.clients.client AS client
UNWIND client.avis.avis AS avis
MERGE (a:AvisClient {id: avis.id})
ON CREATE SET 
  a.commentaire = avis.commentaire,
  a.note = avis.note;
```

## Créer les relations

### Relier les Clients aux Réclamations

Nous allons créer une relation `FAIT_RECLAMATION` entre chaque client et ses réclamations.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///clients.xml' AS url
CALL apoc.load.xml(url) YIELD value AS row
UNWIND row.clients.client AS client
UNWIND client.reclamations.reclamation AS reclamation
MATCH (c:Client {id: client.id})
MATCH (r:Reclamation {id: reclamation.id})
MERGE (c)-[:FAIT_RECLAMATION]->(r);
```

### Relier les Clients aux AvisClient

Nous allons créer une relation `DONNE_AVIS` entre chaque client et ses avis.

Voici la requête Cypher pour cela :

```cypher
WITH 'file:///clients.xml' AS url
CALL apoc.load.xml(url) YIELD value AS row
UNWIND row.clients.client AS client
UNWIND client.avis.avis AS avis
MATCH (c:Client {id: client.id})
MATCH (a:AvisClient {id: avis.id})
MERGE (c)-[:DONNE_AVIS]->(a);
```

## Vérification des données dans Neo4j

Une fois les requêtes exécutées, vérifiez que les nœuds et relations ont bien été créés en exécutant les requêtes suivantes :

### Vérifier les nœuds Client :

```cypher
MATCH (c:Client) RETURN c LIMIT 25;
```

### Vérifier les nœuds Reclamation :

```cypher
MATCH (r:Reclamation) RETURN r LIMIT 25;
```

### Vérifier les nœuds AvisClient :

```cypher
MATCH (a:AvisClient) RETURN a LIMIT 25;
```

### Vérifier les relations entre Client et Reclamation :

```cypher
MATCH (c:Client)-[:FAIT_RECLAMATION]->(r:Reclamation) RETURN c, r LIMIT 25;
```

### Vérifier les relations entre Client et AvisClient :

```cypher
MATCH (c:Client)-[:DONNE_AVIS]->(a:AvisClient) RETURN c, a LIMIT 25;
```
```