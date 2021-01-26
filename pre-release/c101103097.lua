--War Rock Bashileos
local s,id=GetID()
function s.initial_effect(c)
	--If your Earth Warrior monster battles
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	local timing=TIMING_BATTLE_PHASE+TIMING_BATTLE_END+TIMING_DAMAGE_STEP+TIMING_ATTACK+TIMING_BATTLE_START
	e1:SetHintTiming(timing,timing)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Special summon itself from hand/GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Condition check for the Quick Effect
	aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge2:SetOperation(s.checkop)
		Duel.RegisterEffect(ge2,0)
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_CONFIRM)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x25C}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local atg=Duel.GetAttackTarget()
	local ac_chk=ac and ac:IsFaceup() and ac:IsAttribute(ATTRIBUTE_EARTH) and ac:IsRace(RACE_WARRIOR)
	local atg_chk=atg and atg:IsFaceup() and atg:IsAttribute(ATTRIBUTE_EARTH) and atg:IsRace(RACE_WARRIOR)
	if ac_chk then
		Duel.RegisterFlagEffect(ac:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
	if atg_chk then
		Duel.RegisterFlagEffect(atg:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and Duel.GetFlagEffect(tp,id)>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Can attack directly this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3205)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x25C),tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
--Special Summon
function s.cfilter(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsPreviousControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end