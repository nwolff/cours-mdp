from google.cloud import firestore_v1

from . import User, iso_timestamp

print("Connecting to firestore...")
users = firestore_v1.Client().collection("users")
print("Done")


def load_users():
    return [_document_to_user(doc) for doc in users.stream()]


def user_for_name(username):
    user_doc = users.document(username).get()
    if user_doc.exists:
        return _document_to_user(user_doc)


def create_or_update_user(username, encoded_password, strategy_name):
    new_user = User(
        timestamp=iso_timestamp(),
        username=username,
        password=encoded_password,
        strategy=strategy_name,
    )
    users.document(username).set(new_user.to_dict())
    return new_user


def delete_all():
    docs = users.list_documents(page_size=200)
    for doc in docs:
        doc.delete()


def _document_to_user(document) -> User:
    return User.from_dict(document.to_dict())
