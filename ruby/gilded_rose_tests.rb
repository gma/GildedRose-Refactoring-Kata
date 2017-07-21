require File.join(File.dirname(__FILE__), 'gilded_rose')
require 'test/unit'

class TestUntitled < Test::Unit::TestCase
  def update_quality(item)
    GildedRose.new([item]).update_quality()
  end

  def test_aged_brie_quality_increases
    quality = 1
    brie = Item.new('Aged Brie', 1, quality)
    update_quality(brie)
    assert_equal quality + 1, brie.quality
  end

  def test_backstage_pass_quality_increases
    quality = 1
    backstage = Item.new('Backstage passes to a TAFKAL80ETC concert', 1, quality)
    update_quality(backstage)
    assert_equal quality + 3, backstage.quality
  end

  def test_conjured_item_degrades_twice_as_fast
    normal = Item.new('Normal', 1, 2)
    conjured = Item.new('Conjured', 1, 2)
    update_quality(conjured)
    2.times { update_quality(normal) }
    assert_equal normal.quality, conjured.quality
  end

  def test_outdated_conjured_item_degrades_twice_as_fast
    normal = Item.new('Normal', -1, 4)
    conjured = Item.new('Conjured', -1, 4)
    update_quality(conjured)
    2.times { update_quality(normal) }
    assert_equal normal.quality, conjured.quality
  end

  def test_normal_items_go_out_of_date
    sell_in = 1
    normal = Item.new('Normal', sell_in, 0)
    update_quality(normal)
    assert_equal sell_in - 1, normal.sell_in
  end

  def test_sulfuras_does_not_go_out_of_date
    sell_in = 2
    sulfuras = Item.new('Sulfuras, Hand of Ragnaros', sell_in, 2)
    update_quality(sulfuras)
    assert_equal sell_in, sulfuras.sell_in
  end

  def test_outdated_normal_item_degrades_quality
    quality = 4
    sell_in = 0
    normal = Item.new('Normal', sell_in, quality)
    update_quality(normal)
    assert_equal quality - 2, normal.quality
  end

  def test_outdated_brie_increase_quality
    quality = 2
    sell_in = -1
    brie = Item.new('Aged Brie', sell_in, quality)
    update_quality(brie)
    assert_equal quality + 2, brie.quality
  end

  def test_outdated_pass_quality_reduced_to_zero
    quality = 2
    sell_in = -1
    backstage_pass = Item.new('Backstage passes to a TAFKAL80ETC concert', sell_in, quality)
    update_quality(backstage_pass)
    assert_equal 0, backstage_pass.quality
  end

  def test_outdated_sulfuras_quality_doesnt_change
    quality = 2
    sell_in = -1
    sulfuras = Item.new('Sulfuras, Hand of Ragnaros', sell_in, quality)
    update_quality(sulfuras)
    assert_equal quality, sulfuras.quality
  end
end
