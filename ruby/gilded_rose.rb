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

    def modify_quality_when_out_of_date
      modify_quality if out_of_date?
    end
  end

  class NormalStrategy < Strategy
    def modify_quality
      item.quality = item.quality - 1 if item.quality > 0
    end
  end

  class SulfurasStrategy < Strategy
    def modify_quality
    end

    def reduce_days_remaining
    end
  end

  class ConjuredStrategy < Strategy
    def modify_quality
      item.quality = item.quality - 2 if item.quality > 0
    end
  end

  class PerishableStrategy < Strategy
    def increase_quality(&block)
      if item.quality < 50
        item.quality = item.quality + 1
        yield if block_given?
      end
    end
  end

  class AgedBrieStrategy < PerishableStrategy
    def modify_quality
      increase_quality
    end

    def modify_quality_when_out_of_date
      increase_quality if out_of_date?
    end
  end

  class BackstagePassStrategy < PerishableStrategy
    def modify_quality
      increase_quality do
        increase_quality if item.sell_in < 11
        increase_quality if item.sell_in < 6
      end
    end

    def modify_quality_when_out_of_date
      item.quality = 0 if out_of_date?
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
      item.modify_quality_when_out_of_date
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
