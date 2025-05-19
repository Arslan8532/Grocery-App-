from neo4j import GraphDatabase
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class Neo4jConnection:
    def __init__(self, uri: str, user: str, password: str):
        self.uri = uri
        self.user = user
        self.password = password
        self.driver = None

        try:
            # Initialize the Neo4j driver
            self.driver = GraphDatabase.driver(uri, auth=(user, password))
            logger.info(f"Neo4j connection to {uri} established successfully")
        except Exception as e:
            logger.error(f"Error initializing Neo4j connection: {e}")
            raise e

    def close(self):
        """Closes the connection to the database."""
        if self.driver:
            self.driver.close()
            logger.info("Neo4j connection closed.")

    def execute_query(self, query: str, parameters: dict = None):
        """Executes a Neo4j query."""
        try:
            with self.driver.session() as session:
                result = session.run(query, parameters or {})
                return [record.data() for record in result]
        except Exception as e:
            logger.error(f"Error executing query: {e}")
            raise e
