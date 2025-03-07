COPY (SELECT * FROM client) TO 'client.csv' WITH CSV header;
COPY (SELECT * FROM produit) TO 'produit.csv' WITH CSV header;
COPY (SELECT * FROM achat)  TO 'achat.csv' WITH CSV header;
COPY (SELECT * FROM fournisseur) TO 'fournisseur.csv' WITH CSV header;
COPY (SELECT * FROM fournisseur_produit) TO 'fournisseur_produit.csv' WITH CSV header;
