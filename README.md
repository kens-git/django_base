<h1>About</h1>
<p>A containerized Django starter project.</p>
<p>Modified from <a href="">testdriven.io</a>'s tutorial.</p>

<h1>Running Locally</h1>
<code>docker compose -f docker-compose.yml up --build</code>
<h1>Deployment to Staging or Production</h1>
<p>The process is the same for staging and production, with the only difference being
that the production environment is given a real SSL certificate.</p>
<h2>Update Environment Variables:</h2>
<h3>.env.{staging|prod}</h3>
<ul>
    <li>DJANGO_SECRET_KEY</li>
    <li>DJANGO_ALLOWED_HOSTS</li>
    <li>SQL_DATABASE</li>
    <li>SQL_USER</li>
    <li>SQL_PASSWORD</li>
    <li>VIRTUAL_HOST</li>
    <li>LETSENCRYPT_HOST</li>
</ul>
<h3>.env.{staging|prod}.db</h3>
<p>Values should match the previous SQL_* environment variables.</p>
<ul>
    <li>POSTGRES_USER</li>
    <li>POSTGRES_PASSWORD</li>
    <li>POSTGRES_DB</li>
</ul>
<h2>Server Setup</h2>
<p>Set up host server and add root ssh key.</p>
<p>Currently, this project does not add a firewall in the scripts. A firewall should be added manually or through the VPS provider's management functionality.</p>
<h2>Deployment Scripts</h2>
<p>Create ssh key for server user.</p>
<p>Then run:</p>
<ul>
    <li><code>./setup_server.sh</code></li>
    <li><code>./deploy.sh</code></li>
    <li><code>./create_app_su.sh</code> (optional)</li>
</ul>
<h2>Check Deployment</h2>
<code>ssh -i /path/to/ssh_key username@host "docker compose -f docker-compose.{staging|prod}.yml exec web python manage.py check --deploy</code>
