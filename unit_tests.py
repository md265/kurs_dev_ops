import unittest
from unittest.mock import Mock, patch
from myapp.calculator import Calculator
from myapp.user_service import UserService

class CalculatorTest(unittest.TestCase):
    def setUp(self):
        self.calculator = Calculator()
    
    def test_add_positive_numbers(self):
        result = self.calculator.add(2, 3)
        self.assertEqual(result, 5)
    
    def test_add_negative_numbers(self):
        result = self.calculator.add(-2, -3)
        self.assertEqual(result, -5)
    
    def test_divide_by_zero_raises_exception(self):
        with self.assertRaises(ZeroDivisionError):
            self.calculator.divide(10, 0)
    
    def test_multiply_with_zero(self):
        result = self.calculator.multiply(5, 0)
        self.assertEqual(result, 0)

class UserServiceTest(unittest.TestCase):
    def setUp(self):
        self.user_service = UserService()
    
    @patch('myapp.user_service.database')
    def test_get_user_by_id_success(self, mock_database):
        # Arrange
        mock_database.find_user.return_value = {
            'id': 1, 
            'name': 'John Doe', 
            'email': 'john@example.com'
        }
        
        # Act
        user = self.user_service.get_user_by_id(1)
        
        # Assert
        self.assertEqual(user['name'], 'John Doe')
        mock_database.find_user.assert_called_once_with(1)
    
    @patch('myapp.user_service.database')
    def test_get_user_by_id_not_found(self, mock_database):
        # Arrange
        mock_database.find_user.return_value = None
        
        # Act & Assert
        with self.assertRaises(UserNotFoundError):
            self.user_service.get_user_by_id(999)

if __name__ == '__main__':
    unittest.main()
    