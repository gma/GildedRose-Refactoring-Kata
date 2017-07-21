require 'forwardable'

class GildedRose

  class Strategy
    extend Forwardable

    attr_accessor :item
    def_delegators :@item, :name, :sell_in, :sell_in=, :quality, :quality=

    def initialize(item)
      @item = item
    end

    def reduce_days_remaining
      item.sell_in = item.sell_in - 1
    end

    def out_of_date?
      item.sell_in < 1
    end

    def modify_quality
      item.quality = [[0, item.quality + change_in_quality].max, 50].min
    end
  end

  class NormalStrategy < Strategy
    def change_in_quality
      out_of_date? ? -2 : -1
    end
  end

  class SulfurasStrategy < Strategy
    def modify_quality
    end

    def reduce_days_remaining
    end
  end

  class ConjuredStrategy < Strategy
    def change_in_quality
      out_of_date? ? -4 : -2
    end
  end

  class AgedBrieStrategy < Strategy
    def change_in_quality
      out_of_date? ? 2 : 1
    end
  end

  class BackstagePassStrategy < Strategy
    def change_in_quality
      case
      when out_of_date?
        -item.quality
      when item.sell_in < 6
        3
      when item.sell_in < 11
        2
      else
        1
      end
    end
  end

  def initialize(items)
    @items = items.map { |item| strategy_for(item) }
  end

  def strategy_for(item)
    cls = {
      'Aged Brie' => AgedBrieStrategy,
      'Backstage passes to a TAFKAL80ETC concert' => BackstagePassStrategy,
      'Conjured' => ConjuredStrategy,
      'Sulfuras, Hand of Ragnaros' => SulfurasStrategy
    }.fetch(item.name, NormalStrategy)
    cls.new(item)
  end

  def update_quality()
    @items.each do |item|
      item.modify_quality
      item.reduce_days_remaining
    end
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
