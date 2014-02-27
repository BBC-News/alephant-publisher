require 'crimp'

module Alephant
  module Publisher
    class Writer
      attr_reader :mapper, :cache

      def initialize(opts)
        @renderer_id = opts[:renderer_id]

        @cache = Cache.new(
          opts[:s3_bucket_id],
          opts[:s3_object_path]
        )

        @mapper = RenderMapper.new(
          opts[:renderer_id],
          opts[:view_path]
        )

        @lookup_table_name = opts[:lookup_table_name]
      end

      def write(data, version = nil)
        lookup = Lookup.create(@lookup_table_name)

        mapper.generate(data).each do |id, r|
          store(id, r.render, data[:options], version, lookup)
        end

        lookup.batch_process
      end

      private

      def store(id, content, options, version, lookup)
        location = location_for(
          id,
          Crimp.signature(options),
          version
        )

        cache.put(location, content)
        lookup.batch_write(options, location, id)
      end

      def location_for(component_id, options_hash, version = nil)
        base_name = "#{@renderer_id}/#{component_id}/#{options_hash}"
        version ? "#{base_name}/#{version}" : base_name
      end

    end
  end
end
