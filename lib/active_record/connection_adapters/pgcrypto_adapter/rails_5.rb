class ::PG::Connection # :nodoc:
  unless self.public_method_defined?(:async_exec_params)
    remove_method :exec_params
    alias exec_params async_exec
  end
end

module ActiveRecord
  module ConnectionHandling

    def pgcrypto_connection(config, *args, &block)
      conn_params = config.symbolize_keys

      conn_params.delete_if { |_, v| v.nil? }

      # Map ActiveRecords param names to PGs.
      conn_params[:user] = conn_params.delete(:username) if conn_params[:username]
      conn_params[:dbname] = conn_params.delete(:database) if conn_params[:database]

      # Forward only valid config params
      valid_conn_param_keys = PG::Connection.conndefaults_hash.keys + [:requiressl]
      conn_params.slice!(*valid_conn_param_keys)

      # The postgres drivers don't allow the creation of an unconnected PGconn object,
      # so just pass a nil connection object for the time being.
      PGCrypto::Adapter.new(nil, logger, conn_params, config)
    end

  end
end
