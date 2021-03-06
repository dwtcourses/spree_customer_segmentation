module Spree
  module CustomerSegmentation
    module Mysql
      class Cart::DaysFromCartModifiedFilterService < BaseService
        attr_accessor :operator, :values

        SEARCH_LOGIC = {
          gt_eq:   { method: 'custom', logic: 'days_from_cart_modified_gteq' },
          gt:      { method: 'custom', logic: 'days_from_cart_modified_gt' },
          between: { method: 'custom', logic: 'days_from_cart_modified_between' },
          eq:      { method: 'custom', logic: 'days_from_cart_modified_eq' },
          not_eq:  { method: 'custom', logic: 'days_from_cart_modified_not_eq' },
          lt_eq:   { method: 'custom', logic: 'days_from_cart_modified_lteq' },
          lt:      { method: 'custom', logic: 'days_from_cart_modified_lt' },
          blank:   { method: 'custom', logic: 'days_from_cart_modified_blank' }
        }

        def initialize(collection, operator, values)
          @operator = operator
          @values = values
          super(collection)
        end

        def filter_data
          perform
        end

        def query
          user_collection.with_items_in_cart.
                      select("spree_users.id, DATE(MAX(spree_orders.updated_at)) as cart_modified_date").
                      group('spree_users.id').distinct
        end

        def days_from_cart_modified_gteq
          query.having("cart_modified_date <= ?", required_date)
        end

        def days_from_cart_modified_gt
          query.having("cart_modified_date < ?", required_date)
        end

        def days_from_cart_modified_lt
          query.having("cart_modified_date > ?", required_date)
        end

        def days_from_cart_modified_lteq
          query.having("cart_modified_date >= ?", required_date)
        end

        def days_from_cart_modified_eq
          query.having("cart_modified_date = ?", required_date)
        end

        def days_from_cart_modified_not_eq
          query.having("cart_modified_date != ?", required_date)
        end

        def days_from_cart_modified_between
          return ::Spree::User.none if (values[0].nil? || values[1].nil?)

          first_date  = (current_utc_time - values[0].to_i.days).to_date
          second_date = (current_utc_time - values[1].to_i.days).to_date

          query.having("cart_modified_date >= ? AND cart_modified_date <= ?", second_date, first_date)
        end

        def days_from_cart_modified_blank
          values ? user_collection.without_items_in_cart : user_collection.with_items_in_cart
        end

        def required_date
          (current_utc_time - values.to_i.days).to_date
        end

      end
    end
  end
end
