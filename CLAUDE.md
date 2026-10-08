# cours-mdp

## Re-registration overwrites the account — by design

Registering an existing username overwrites that account (`createOrUpdateUser` in `src/storage.ts`, allowed by `firestore.rules`). This is intentional: the course has students re-register the same name with different password strategies (plaintext → rot13 → md5 → salted_md5) to compare what gets stored.

Never block, warn against or add friction to re-registration (no "ce nom est déjà pris", no confirmation step). Telling the student the account was replaced ("Le compte a été remplacé") is fine.
