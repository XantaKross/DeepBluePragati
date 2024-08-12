from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

class CustomUserManager(BaseUserManager):
    use_in_migrations = True

    def create_user(self, email, password, **kwargs):
        if not email:
            raise ValueError('Users must have a valid email address')
        #elif not username:
        #    raise ValueError('Users must have a valid username')

        user = self.model(
            #username=username,
            email=self.normalize_email(email),
            **kwargs
        )

        user.set_password(password)
        user.is_active = True
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password, **kwargs):
        kwargs.setdefault('is_superuser', True)

        if not kwargs.get('is_superuser'):
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **kwargs)

class CustomUser(AbstractBaseUser):
    id = models.AutoField(primary_key=True)
    #username = models.CharField(max_length=30, blank=False)
    email = models.EmailField(unique=True, blank=False)
    is_superuser = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    #REQUIRED_FIELDS = ["username"]

    def identify(self): return self.email

    def has_perm(self, perm):
        if self.is_active and self.is_superuser:
            return True
        return False

    def __str__(self):
        return f"email: {self.email}\n password: {self.password}"