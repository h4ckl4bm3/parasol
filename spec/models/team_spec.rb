require 'spec_helper'

describe Team do
  describe '#password=' do
    before do
      @team = create(:team, password: 'abc')
    end
    context 'if the valid password is given' do
      before do
        @team.password = 'def'
      end
      it 'correctly update the password' do
        expect(@team.save).to be_true
      end
      it 'successfully authenticate with the new password' do
        expect(@team.authenticate('def')).to eq @team
      end
    end
    context 'if the empty password is given' do
      it 'fails to update the password' do
        @team.password = ''
        expect(@team.save).to be_false
      end
    end
  end

  describe '#authenticate' do
    before do
      @team = create(:team, password: 'abc')
    end
    subject { @team }
    context 'if the correct password is given' do
      it 'authenticates correctly' do
        expect(subject.authenticate('abc')).to eq @team
      end
    end
    context 'if the wrong password is given' do
      it 'fails to authenticate' do
        expect(subject.authenticate('def')).to be_nil
      end
    end
  end

  describe '#forget_password!' do
    before do
      @old_pw = 'test'
      @team = create(:team, password: @old_pw)
      @new_pw = @team.forget_password!
    end
    it 'returns the new password' do
      expect(@old_pw).not_to eq @new_pw
    end
    it 'successfully authenticate with the new password' do
      expect(@team.authenticate(@new_pw)).to eq @team
    end
  end

  describe '#suspended?' do
    before do
      @team = create(:team)
    end
    context 'if the team is not suspended' do
      it 'returns false' do
        expect(@team.suspended?).to be_false
      end
    end
    context 'if the team is suspended' do
      before do
        @team.suspend!
      end
      it 'returns true' do
        expect(@team.suspended?).to be_true
      end
    end
  end

  describe '#suspend!' do
    before do
      @team = create(:team)
      @suspend_until = Time.now.tomorrow
    end
    context 'if the team is not suspended' do
      before do
        @team.suspend!(@suspend_until)
      end
      it 'suspends the team' do
        expect(@team.suspended?).to be_true
        expect(@team.suspended_until).to eq @suspend_until
      end
    end
  end

  describe '#resume!' do
    before do
      @team = create(:team)
    end
    context 'if the team is not suspended' do
      it 'does nothing' do
        @team.resume!
        expect(@team.suspended?).to be_false
      end
    end
    context 'if the team is suspended' do
      before do
        @team.suspend!
      end
      it 'resumes the team' do
        @team.resume!
        expect(@team.suspended?).to be_false
      end
    end
  end

  describe '#point' do
    subject { @team.point }
    context 'if the team has no members' do
      before do
        @team = create(:team, players: [])
      end
      it 'returns 0' do
        expect(subject).to eq 0
      end
    end
    context 'if the team has some members' do
      before do
        @team = create(:team, players: [])
        @players = 2.times.map {create(:player)}
        @players.each {|p| @team.players << p}
        challenge = create(:challenge)
        @players[0].submit(challenge, challenge.flags[0].flag)

        challenge = build(:challenge, flags: [])
        f = challenge.flags.build(flag: 'FLAG_abcde', point: 300)
        challenge.save!
        f.save!
        @players[1].submit(challenge, challenge.flags[0].flag)
      end
      it "returns summation of the players' point" do
        expect(subject).to eq @players.map{|p| p.point}.inject(:+)
      end
    end
  end
end
