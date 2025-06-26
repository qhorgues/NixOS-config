{ pkgs, ... }:

let
  dbName = "zuka_bot";
  dbUser = "zuka_bot";
  userPassword = "1234";
  postgresPassword = "1234";
in
{

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "zuka_bot" ];
    ensureUsers = [
      {
        name = "zuka_bot";
        ensureDBOwnership =true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
    # type   database  DBuser                   auth-method
      host   all       all            127.0.0.1/32 trust
      host   all       all            ::1/128      trust
      local  all       postgres       trust
      local  zuka_bot   zuka_bot      trust
      '';
    initialScript = pkgs.writeText "init.sql" ''
      -- Create the database
      CREATE DATABASE zuka_bot;
      \c zuka_bot;

      CREATE TABLE server (
          guild_id BIGINT PRIMARY KEY,
          channel_id BIGINT NOT NULL
      );

      CREATE TABLE users (
        user_id                BIGINT   NOT NULL,
        guild_id               BIGINT   NOT NULL
                                    REFERENCES server(guild_id)
                                    ON DELETE CASCADE,
        replay_count           INT      DEFAULT 0,
        pending_replay_count   INT      DEFAULT 0,
        username               VARCHAR(255) NOT NULL,
        PRIMARY KEY (user_id, guild_id)
      );


      CREATE TABLE replays (
          message_id BIGINT PRIMARY KEY,
          user_id    BIGINT NOT NULL,
          guild_id   BIGINT NOT NULL,
          rank VARCHAR(50) NOT NULL,
          FOREIGN KEY (user_id, guild_id)
              REFERENCES users(user_id, guild_id)
              ON DELETE CASCADE
      );

      -- REVOKE ALL PRIVILEGES ON DATABASE ${dbName} FROM ${dbUser};
      -- REVOKE ALL PRIVILEGES ON SCHEMA public FROM ${dbUser};
      GRANT CONNECT ON DATABASE ${dbName} TO ${dbUser};
      GRANT USAGE ON SCHEMA public TO ${dbUser};

      \c zuka_bot;

      GRANT SELECT, INSERT, UPDATE, DELETE  ON TABLE server, users, replays TO ${dbUser};
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${dbUser};

      \c postgres;

      ALTER USER postgres WITH PASSWORD ${postgresPassword};
      ALTER USER ${dbUser} WITH PASSWORD ${userPassword};
      '';
  };

  systemd.services.postgresql = {
    wantedBy = [ "multi-user.target" ];
  };
}
