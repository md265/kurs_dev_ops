from myapp.errors import UserNotFoundError

# symulacja modułu database — w testach będzie mockowany
class FakeDatabase:
    def find_user(self, user_id):
        # normalnie byłoby np. zapytanie do bazy danych
        return None

database = FakeDatabase()


class UserService:
    def get_user_by_id(self, user_id):
        user = database.find_user(user_id)
        if not user:
            raise UserNotFoundError(f"User with id {user_id} not found")
        return user