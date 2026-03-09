import Fastify from 'fastify';

export function buildServer() {
  const server = Fastify({
    logger: {
      level: process.env.LOG_LEVEL ?? 'info',
    },
  });

  server.get('/', async () => ({
    service: '${{ values.name }}',
    description: '${{ values.description }}',
  }));

  server.get('/health/live', async () => ({
    status: 'ok',
    service: '${{ values.name }}',
  }));

  server.get('/health/ready', async () => ({
    status: 'ready',
    service: '${{ values.name }}',
  }));

  return server;
}
