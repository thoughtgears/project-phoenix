import click
import uuid
from google.cloud import firestore


@click.command()
@click.option('--project', help='The project ID (e.g., example-dev).', type=str, required=True)
def generate(project, num_docs=100):
    db = firestore.Client(project=project)
    collection_name = "random-documents"

    for _ in range(num_docs):
        doc_id = str(uuid.uuid4())
        doc_ref = db.collection(collection_name).document(doc_id)
        doc_ref.set({
            'something': {
                'akey': f'value-{doc_id}'
            }
        })


if __name__ == '__main__':
    generate()
