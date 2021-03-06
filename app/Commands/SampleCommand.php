<?php

namespace Remp\Mailer\Commands;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class SampleCommand extends Command
{
    public function __construct()
    {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this->setName('mail:sample-command');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        /**
         * Put any custom code here
         */
        $output->writeln('<info>Mailer</info> - running sample command');
        return Command::SUCCESS;
    }
}