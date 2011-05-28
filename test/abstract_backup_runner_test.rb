
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mongo_cluster_backup/runner/dummy_backup_runner'

class AbstractBackupRunnerTest < Test::Unit::TestCase

  NODES = [1,2,3]

  def setup
    @runner = MongoBackup::BackupRunner::DummyRunner.new(NODES)
  end

  def test_backups_making
    @runner.run
    assert_equal NODES, @runner.backups
  end

  def test_backups_nowait
    @runner.run(:wait => false)
    assert_equal NODES, @runner.backups
    assert_equal [], @runner.waiting
    @runner.update_waiting
    assert_equal [], @runner.waiting
  end

  def test_backups_waiting
    @runner.run(:wait => true)
    assert_equal NODES, @runner.backups
    assert_equal NODES, @runner.waiting
    @runner.update_waiting
    assert_equal [], @runner.waiting
  end
end
