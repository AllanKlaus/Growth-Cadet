module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        @dns = DnsRecord.search(PAGINATION, offset, params[:included], params[:excluded])

        render json: {
          total_records: @dns[:records].size,
          records: @dns[:records],
          related_hostnames: @dns[:related_hostnames],
        }, status: :ok
      rescue ActionController::ParameterMissing
        render json: {}, status: :unprocessable_entity
      end

      # POST /dns_records
      def create
        hostnames = params[:dns_records][:hostnames_attributes].map do |hostname|
          Hostname.find_or_initialize_by(hostname.to_unsafe_h)
        end

        @dns_record = DnsRecord.create!(ip: params[:dns_records][:ip], hostnames: hostnames)
        render json: { id: @dns_record.id }, status: :created
      rescue StandardError => e
        render json: { error: e }, status: :unprocessable_entity
      end

      private

      def dns_record_params
        params.require(:dns_record).permit(:ip, hostnames_attributes: [:hostname])
      end

      def page
        @page ||= params.require(:page).to_i - 1
      end

      def offset
        page * PAGINATION
      end
    end
  end
end
