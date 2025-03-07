INSERT INTO `client` (`id`, `nom`, `prenom`, `date_naissance`, `email`, `contact`, `adresse`) VALUES ('1', 'Sanou', 'Ana', '2025-03-04', 'ana@gmail.com', '2557886567', 'rue 22');

INSERT INTO `produit` (`id`, `nom`, `description`, `quantite`, `prix`, `statut`, `categorie`) VALUES ('1', 'moto', 'moto d\'occasion', '20', '20000', 'terminé', 'couper');

INSERT INTO `achat` (`id`, `id_client`, `id_produit`, `date_achat`, `statut`) VALUES ('1', '1', '1', '2025-03-04', 'valide');

INSERT INTO `fournisseur` (`id`, `nom`, `prenom`, `contact`, `adresse`) VALUES ('1', 'Traore', 'sisi', '255788656733', 'Rue 23');


INSERT INTO `fournisseur_produit` (`id_fournisseur`, `id_produit`, `quantite_fournie`, `date_fourniture`) VALUES ('1', '1', '20', '2025-03-18');


