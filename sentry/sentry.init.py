from sentry.utils.runner import configure
configure()

from sentry.models import Team, Project, ProjectKey, User, Organization

user = User()
user.username = 'admin'
user.email = 'admin@localhost'
user.is_superuser = True
user.set_password('admin')
user.save()

organization = Organization()
organization.name = 'MyOrg'
organization.owner = user
organization.save()

team = Team()
team.name = 'Sentry'
team.organization = organization
team.owner = user
team.save()

project = Project()
project.team = team
project.name = 'Default'
project.organization = organization
project.save()

f = open('dsn', 'wb')
key = ProjectKey.objects.filter(project=project)[0]
f.write(key.get_dsn())
f.close()