from flask import Flask, render_template, request
from neo4j import GraphDatabase

# Initialisation de Flask
app = Flask(__name__)

# Connexion à Neo4j
driver = GraphDatabase.driver("bolt://localhost:7690", auth=("neo4j", "12345678"))

def run_query(query):
    """Exécute une requête Cypher et retourne les résultats."""
    with driver.session() as session:
        result = session.run(query)
        return [dict(record) for record in result]

@app.route("/", methods=["GET", "POST"])
def index():
    results = None
    if request.method == "POST":
        # Récupérer la requête Cypher saisie par l'utilisateur
        query = request.form.get("query")
        if query:
            try:
                results = run_query(query)
            except Exception as e:
                results = {"error": str(e)}
    return render_template("index.html", results=results)

if __name__ == "__main__":
    app.run(debug=True)