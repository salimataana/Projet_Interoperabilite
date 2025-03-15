from flask import Flask, render_template, request
from neo4j import GraphDatabase

app = Flask(__name__)

NEO4J_URI = "bolt://localhost:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "12345678"

driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

def run_query(query):
    with driver.session() as session:
        result = session.run(query)
        return [dict(record) for record in result]

def get_clients():
    query = "MATCH (c:Client) RETURN c.id AS id, c.nom AS nom, c.prenom AS prenom"
    return run_query(query)

def get_fournisseurs():
    query = "MATCH (f:Fournisseur) RETURN f.id AS id, f.nom AS nom"
    return run_query(query)

@app.route("/", methods=["GET", "POST"])
def index():
    results = None
    clients = get_clients()
    fournisseurs = get_fournisseurs()
    
    if request.method == "POST":
        query = request.form.get("query")
        if query:
            try:
                results = run_query(query)
            except Exception as e:
                results = {"error": str(e)}
    
    return render_template("index.html", results=results, clients=clients, fournisseurs=fournisseurs)

if __name__ == "__main__":
    app.run(debug=True, port=5001)
