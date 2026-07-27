(() => {
  'use strict';

  const status = document.getElementById('invite-status');

  const renderInvitationState = () => {
    const fragment = new URLSearchParams(window.location.hash.slice(1));
    const token = fragment.get('invite') || '';
    const hasOnlyInviteField = Array.from(fragment.keys()).every((key) => key === 'invite');
    const hasValidInvitation = hasOnlyInviteField && /^[A-Za-z0-9_-]{43}$/.test(token);

    if (hasValidInvitation) {
      status.textContent =
        'Invitation link ready. The secret stays in this browser address and is not sent to this website.';
      status.dataset.state = 'ready';
      return;
    }

    status.textContent = 'This invitation link is invalid or incomplete. Ask the sender to send a new invitation.';
    status.dataset.state = 'invalid';
  };

  renderInvitationState();
  window.addEventListener('hashchange', renderInvitationState);
})();
