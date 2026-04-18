class Config:
    """Application configuration"""
    # Defaults (dev profile)
    PROFILE = 'dev'
    DEBUG = True
    SECRET_KEY = 'Aniwe2024!'

    # Flask Configuration
    HOST = '0.0.0.0'
    PORT = 8080

    # MySQL Configuration
    MYSQL_HOST = 'localhost'
    MYSQL_USER = 'root'
    MYSQL_PASSWORD = 'admin123'
    MYSQL_DB = 'AniweDB'
    MYSQL_PORT = 3306

    PROFILES = {
        'dev': {
            'DEBUG': True,
            'SECRET_KEY': 'Aniwe2024!',
            'HOST': '0.0.0.0',
            'PORT': 8080,
            'MYSQL_HOST': 'localhost',
            'MYSQL_USER': 'root',
            'MYSQL_PASSWORD': ' ',
            'MYSQL_DB': 'AniweDB',
            'MYSQL_PORT': 3306,
        },
        'gcp': {
            'DEBUG': True,
            'SECRET_KEY': 'Aniwe2024!',
            'HOST': '0.0.0.0',
            'PORT': 8080,
            'MYSQL_HOST': '35.233.192.65',
            'MYSQL_USER': 'aniwe_admin',
            'MYSQL_PASSWORD': '',
            'MYSQL_DB': 'AniweDB',
            'MYSQL_PORT': 3306,
        },
    }

    @classmethod
    def load_profile(cls, profile_name):
        """Load one of the built-in profiles: dev or gcp."""
        profile = (profile_name or 'dev').lower()
        if profile not in cls.PROFILES:
            raise ValueError("Invalid profile. Use 'dev' or 'gcp'.")

        values = cls.PROFILES[profile]
        cls.PROFILE = profile
        for key, value in values.items():
            setattr(cls, key, value)
