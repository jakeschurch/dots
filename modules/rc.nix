_: {
  home = {
    file = {
      ".inputrc".text = ''
        set editing-mode vi
        set convert-meta on
        set show-all-if-ambiguous on
        set horizontal-scroll-mode Off
        set bell-style none
        set keymap vi-command

        # Color files by types
        # Note that this may cause completion text blink in some terminals (e.g. xterm).
        set colored-stats On

        # Append char to indicate type
        set visible-stats On

        # Mark symlinked directories
        set mark-symlinked-directories On

        # Color the common prefix
        set colored-completion-prefix On

        # Color the common prefix in menu-complete
        set menu-complete-display-prefix On

      '';

      ".pylintrc".text = ''
        [LOGGING]
        logging-format-style=new
        disable=W1203

        [FORMAT]
        max-line-length=110
      '';

      ".editrc".text = ''
        bind -v
      '';

      ".Xresources".text = ''
        Xft.dpi: 144
      '';

      ".psqlrc".text = ''
        -- tab-complete entries as uppercase
        \set COMP_KEYWORD_CASE upper

        -- expanded output
        \x auto
        \set HISTCONTROL ignoredups
        \set VERBOSITY verbose

        -- separate history entries by host + dbname
        \set HISTFILE ~/.cache/psql-history/.psql_history-:HOST-:DBNAME

        -- custom db null values
        \pset null '(null)'

        -- prompt for starting queries
        \set PROMPT1 '%M %n@%/%R%#%x '
        -- prompt for query fragments by <CR>
        \set PROMPT2 '%M %n@%/%R%#%x '

        \set PSL_EDITOR nvim

        \set ON_ERROR_ROLLBACK on

        -- display query times
        \timing
        \encoding unicode

        -- custom commands
        \set clear '\\! clear;'
        \set version 'SELECT version();'
        \set conninfo 'select usename, count(*) from pg_stat_activity group by usename;'

        \set activity 'select datname, pid, username, application_name,client_addr, client_hostname, client_port, query, state from pg_stat_activity;'

        \set waits 'SELECT pg_stat_activity.pid, pg_stat_activity.query, pg_stat_activity.waiting, now() - pg_stat_activity.query_start AS \"totaltime\", pg_stat_activity.backend_start FROM pg_stat_activity WHERE pg_stat_activity.query !~ \'%IDLE%\'::text AND pg_stat_activity.waiting = true;'

        \set dbsize 'SELECT datname, pg_size_pretty(pg_database_size(datname)) db_size FROM pg_database ORDER BY db_size;'

        \set tablesize 'SELECT nspname || \'.\' || relname AS \"relation\", pg_size_pretty(pg_relation_size(C.oid)) AS "size" FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT IN (\'pg_catalog\', \'information_schema\') ORDER BY pg_relation_size(C.oid) DESC LIMIT 40;'

        \set uselesscol 'SELECT nspname, relname, attname, typname, (stanullfrac*100)::int AS null_percent, case when stadistinct >= 0 then stadistinct else abs(stadistinct)*reltuples end AS \"distinct\", case 1 when stakind1 then stavalues1 when stakind2 then stavalues2 end AS \"values\" FROM pg_class c JOIN pg_namespace ns ON (ns.oid=relnamespace) JOIN pg_attribute ON (c.oid=attrelid) JOIN pg_type t ON (t.oid=atttypid) JOIN pg_statistic ON (c.oid=starelid AND staattnum=attnum) WHERE nspname NOT LIKE E\'pg\\\\_%\' AND nspname != \'information_schema\' AND relkind=\'r\' AND NOT attisdropped AND attstattarget != 0 AND reltuples >= 100 AND stadistinct BETWEEN 0 AND 1 ORDER BY nspname, relname, attname;'

        \set uptime 'select now() - pg_postmaster_start_time() AS uptime;'

        \set longqueries 'select pid, application_name, backend_type, now() - query_start as query_age, now() - xact_start as xact_age, state, substr(regexp_replace(query, /'\s*/', /' /'), 1, 30) as query from pg_stat_activity where true and state != /'idle/' and pid != pg_backend_pid() order by xact_start desc;'
      '';

      ".ripgreprc".text = ''
        --max-columns=150
        --max-columns-preview
        --glob=!{git,node_modules,dist}/*
        --smart-case
      '';
    };

    activation.psql-setup = ''
      [ -d ~/.cache/psql-history ] || mkdir -p ~/.cache/psql-history
    '';
  };

  xdg.configFile.".yamllint".text = ''
    # yaml
    extends: default

    rules:
      braces: enable
      brackets: enable
      colons: enable
      commas: enable
      comments: disable
      comments-indentation: disable
      document-end: disable
      document-start:
        level: warning
      empty-lines: enable
      empty-values: disable
      float-values: disable
      hyphens: enable
      indentation: enable
      key-duplicates: enable
      key-ordering: disable
      line-length: disable
      new-line-at-end-of-file: enable
      new-lines: enable
      octal-values: disable
      quoted-strings: disable
      trailing-spaces: enable
      truthy:
        level: warning
  '';
}
