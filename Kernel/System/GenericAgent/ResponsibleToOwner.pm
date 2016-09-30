# --
# Copyright (C) 2016 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::GenericAgent::ResponsibleToOwner;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::Log
    Kernel::System::Ticket
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # check needed stuff
    for my $Needed (qw(TicketID) ) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $UseResponsible = $ConfigObject->Get('Ticket::Responsible');
    return 1 if !$UseResponsible;

    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
        UserID   => 1,
    );

    return if !$Ticket{ResponsibleID} || $Ticket{ResponsibleID} == 1;
    return if $Ticket{ResponsibleID} == $Ticket{OwnerID};

    # reset owner
    $TicketObject->TicketOwnerSet(
        TicketID  => $Param{TicketID},
        NewUserID => $Ticket{ResponsibleID},
        UserID    => 1,
    );

    return 1;
}

1;
