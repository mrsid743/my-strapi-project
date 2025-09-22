module.exports = ({ env }) => ({
  defaultConnection: 'default',
  connections: {
    default: {
      connector: 'bookshelf',
      settings: {
        client: 'postgres',
        host: env('DATABASE_HOST', 'postgres_db'),
        port: env.int('DATABASE_PORT', 5432),
        database: env('DATABASE_NAME', 'strapidb'),
        username: env('DATABASE_USERNAME', 'strapiuser'),
        password: env('DATABASE_PASSWORD', 'strapipassword'),
        ssl: env.bool('DATABASE_SSL', false),
      },
      options: {}
    },
  },
});
