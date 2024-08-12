#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys

# need to handle manual clean up of AI model's variables.

#def on_server_exit(signal_, frame_):
#    print("ENDING...")
#    model.cleanupGPU()

#    sys.exit(0)


def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Server.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc

#        import signal
#        from Server.views import on_server_exit

            # Register signal handlers
#            signal.signal(signal.SIGINT, on_server_exit)
#            signal.signal(signal.SIGTERM, on_server_exit)



    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
